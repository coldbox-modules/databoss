/**
 * Copyright 2012 Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * ---
 * The metadata service is used to talk to hibernate and the CFC entities
 * to get metadata and persistence information to build their internal
 * metadata dictionaries.
 *
 * Available DataBoss annotations:
 * Component Tag
 * - db_sortBy : Sorting of the entity
 * - displayName : The name to show for the entity
 *
 * Property tag
 * - db_html (string=text) : The available HTML controls: text, email, password, textarea, richtext, radio, select
 * - db_display (boolean=true) : Display the property in the listing grid
 * - db_validate (string="") : A custom regex to do validation for the property using ColdBox validation
 * - db_helpText (string="") : The help text to display in the create and update forms
 * - db_labelText (string=property name) : The label text to display in the create and update forms
 * - db_maxLength (numeric="") : The maximum size of the value of this property, also used on ColdBox validation
 * - db_displayColumns (string=primarykey) : A list of columns to display on singular relations when building the create and update forms. Defaults to primary key values unless used
 *
 * @author Luis Majano
 */
component accessors="true" singleton {

	// DI
	property name="logger"     inject="logbox:logger:databoss";
	property name="ormService" inject="entityService";

	// Properties
	property name="dictionary"        type="struct";
	property name="persistedEntities" type="Array";

	/**
	 * Constructor
	 */
	MetadataService function init(){
		// Create instance scope
		variables.dictionary        = {};
		variables.persistedEntities = [];

		return this;
	}

	/**
	 * Convert a Hibernate datatype to CF data type:
	 * https://www.hibernate.org/hib_docs/v3/api/org/hibernate/type/package-summary.html
	 *
	 * @hibernateType The hibernate type to convert
	 */
	public string function getCFDataType( hibernateType ){
		switch ( arguments.hibernateType ) {
			case "short":
			case "integer":
			case "big_integer":
			case "int":
			case "long":
			case "big_decimal":
			case "float":
			case "double": {
				return "string";
			}
			case "boolean":
			case "yes_no":
			case "true_false":
			case "byte": {
				return "boolean";
			}
			case "date":
			case "timestamp":
			case "dbtimestamp":
			case "calendar":
			case "calendar_date": {
				return "date";
			}
			case "binary":
			case "serializable":
			case "blob": {
				return "binary";
			}
			// locale, timezone, currency, character, char, text, clob, varchar, class
			default:
				return "string";
		}
	}

	/**
	 * prepare the dictionary for an entity by name
	 *
	 * @entityName The entity
	 */
	MetadataService function prepareDictionary( required entityName ){
		// Get a new entity for MD purposes
		var oEntity         = entityNew( arguments.entityName );
		// CF metadata
		var entityMD        = getMetadata( oEntity );
		// Hibernate Metadata
		var hibernateMD     = getClassMetadata( arguments.entityName );
		// Get a new entity MD entry to populate
		var mdEntry         = getNewEntityMDEntry();
		// Normalize the entity properties for MD lookups
		var normalizedProps = {};
		normalizeProperties( entityMD, normalizedProps );

		// Attach entry to dictionary so we can have reference calls:
		variables.dictionary[ arguments.entityName ] = mdEntry;

		// Start populating Entity Data with defaults
		mdEntry.name        = arguments.entityName;
		mdEntry.displayName = arguments.entityName;
		if ( structKeyExists( entityMD, "displayName" ) ) {
			mdEntry.displayName = entityMD.displayName;
		}

		// Ask hibernate for the pk column
		mdEntry.pk.name  = getPKInfo( hibernateMD );
		mdEntry.pk.label = mdEntry.pk.name;

		// Get Label for pk from normalized properties
		if ( len( normalizedProps[ mdEntry.pk.name ].labelText ) ) {
			mdEntry.pk.label = normalizedProps[ mdEntry.pk.name ].labelText;
		}


		// Join Column?
		if ( structKeyExists( entityMD, "joinColumn" ) ) {
			mdEntry.joinColumn = entityMD.joinColumn;
		}
		// Read Only?
		if ( structKeyExists( entityMD, "readOnly" ) ) {
			mdEntry.readOnly = entityMD.readOnly;
		}
		// Sort By metadata?
		mdEntry.sortBy = mdEntry.pk.name;
		if ( structKeyExists( entityMD, "db_sortBy" ) ) {
			mdEntry.sortBy = entityMD.db_sortBy;
		}

		// Process persisted properties now
		var props = hibernateMD.getEntityMetaModel().getProperties();
		for ( var x = 1; x lte arrayLen( props ); x++ ) {
			var pType = props[ x ].getType();

			// Only non collection or entity properties, the rest will be done as collections later
			if ( NOT pType.isEntityType() AND NOT pType.isCollectionType() ) {
				var pEntry      = getNewPropertyMDEntry();
				// Properties from Hibernate MD
				pEntry.name     = props[ x ].getName();
				pEntry.insert   = props[ x ].isInsertable();
				pEntry.update   = props[ x ].isUpdateable();
				pEntry.notNull  = not props[ x ].isNullable();
				pEntry.dataType = getCFDataType( pType.getName() );
				// Extra MD For DataBoss
				if ( structKeyExists( normalizedProps, pEntry.name ) ) {
					pEntry.fieldType     = normalizedProps[ pEntry.name ].fieldType;
					pEntry.display       = normalizedProps[ pEntry.name ].display;
					pEntry.displayCreate = normalizedProps[ pEntry.name ].displayCreate;
					pEntry.displayUpdate = normalizedProps[ pEntry.name ].displayUpdate;
					pEntry.html          = normalizedProps[ pEntry.name ].html;
					pEntry.helpText      = normalizedProps[ pEntry.name ].helpText;
					pEntry.labelText     = normalizedProps[ pEntry.name ].labelText;
					// Regular properties default label to name
					if ( !len( pEntry.labelText ) ) {
						pEntry.labelText = pEntry.name;
					}
					pEntry.validate     = normalizedProps[ pEntry.name ].validate;
					pEntry.maxLength    = normalizedProps[ pEntry.name ].maxLength;
					pEntry.placeholder  = normalizedProps[ pEntry.name ].placeholder;
					pEntry.dateformat   = normalizedProps[ pEntry.name ].dateformat;
					pEntry.timeformat   = normalizedProps[ pEntry.name ].timeformat;
					pEntry.showDate     = normalizedProps[ pEntry.name ].showDate;
					pEntry.showTime     = normalizedProps[ pEntry.name ].showTime;
					pEntry.timeMeridian = normalizedProps[ pEntry.name ].timeMeridian;
					pEntry.timeSeconds  = normalizedProps[ pEntry.name ].timeSeconds;
					pEntry.options      = normalizedProps[ pEntry.name ].options;
					pEntry.optionsUDF   = normalizedProps[ pEntry.name ].optionsUDF;
				}
				// Build Constraints for insertion
				if ( pEntry.insert and pEntry.notNull ) {
					mdEntry.insertConstraints[ pEntry.name ] = { required : true, type : pEntry.dataType };
					if ( isNumeric( pEntry.maxLength ) ) {
						mdEntry.insertConstraints[ pEntry.name ].size = "1..#pEntry.maxLength#";
					}
					if ( len( pEntry.validate ) ) {
						mdEntry.insertConstraints[ pEntry.name ].regex = pEntry.validate;
					}
				}

				// Build Constraints for update
				if ( pEntry.update and pEntry.notNull ) {
					mdEntry.updateConstraints[ pEntry.name ] = { required : true, type : pEntry.dataType };
					if ( isNumeric( pEntry.maxLength ) ) {
						mdEntry.updateConstraints[ pEntry.name ].size = "1..#pEntry.maxLength#";
					}
					if ( len( pEntry.validate ) ) {
						mdEntry.updateConstraints[ pEntry.name ].regex = pEntry.validate;
					}
				}

				// Append to dictionary
				arrayAppend( mdEntry.properties, pEntry );
			}
			// Collection Relations: OneToMany and ManyToMany Relationships
			else if ( pType.isCollectionType() ) {
				mdEntry.hasCollections = true;
				var newCollection      = {
					alias          : props[ x ].getName(),
					labelText      : normalizedProps[ props[ x ].getName() ].labelText,
					displayColumns : normalizedProps[ props[ x ].getName() ].displayColumns,
					sourceEntity   : pType.getAssociatedEntityName( ormGetSessionFactory() ),
					pk             : [],
					sortBy         : "",
					singularName   : normalizedProps[ props[ x ].getName() ].singularName,
					isOneToMany    : ormGetSessionFactory().getCollectionMetadata( pType.getRole() ).isOneToMany(),
					notNull        : not props[ x ].isNullable()
				};
				// Get relation entity dictionary
				var tmpDictionary    = getDictionaryEntry( newCollection.sourceEntity );
				newCollection.pk     = tmpDictionary.pk;
				newCollection.sortBy = tmpDictionary.sortBy;

				// Collections default label to source entity's displayName
				if ( !len( newCollection.labelText ) ) {
					newCollection.labelText = tmpDictionary.displayName;
				}

				// Store Relation
				arrayAppend( mdEntry.collections, newCollection );
			}
			// Singular Relations: OneToOne, ManyToOne Relationships
			else if ( pType.isEntityType() ) {
				// Define the relationship structure
				mdEntry.hasSingularRelations = true;
				var newRelation              = {
					alias          : props[ x ].getName(),
					labelText      : normalizedProps[ props[ x ].getName() ].labelText,
					sourceEntity   : pType.getAssociatedEntityName(),
					displayColumns : normalizedProps[ props[ x ].getName() ].displayColumns,
					isOneToOne     : pType.isOneToOne(),
					notNull        : not props[ x ].isNullable(),
					display        : normalizedProps[ props[ x ].getName() ].display
				};
				var tmpDictionary = getDictionaryEntry( newRelation.sourceEntity );
				newRelation.pk    = tmpDictionary.pk;
				// Collections default label to source entity's displayName
				if ( !len( newRelation.labelText ) ) {
					newRelation.labelText = tmpDictionary.displayName;
				}
				// add it to relations array
				arrayAppend( mdEntry.singularRelations, newRelation );
			}
		}
		// end for loop in properties

		if ( logger.canDebug() ) {
			logger.debug(
				"Finished preparing dictionary for: #arguments.entityName#",
				variables.dictionary[ arguments.entityName ]
			);
		}

		return this;
	}

	/**
	 * Clean the metadata Dictionary
	 */
	MetadataService function cleanDictionary(){
		variables.dictionary        = {};
		variables.persistedEntities = [];
		return this;
	}

	/**
	 * Get a dictionary structure for an entity. If dictionary not found, we lazy load it
	 *
	 * @entityName The entity name
	 */
	struct function getDictionaryEntry( required entityName ){
		if ( not structKeyExists( variables.dictionary, arguments.entityName ) ) {
			// dictionary not found, prepare it
			prepareDictionary( arguments.entityName );
		}
		// Return md dictionary
		return variables.dictionary[ arguments.entityName ];
	}

	/**
	 * Returns an array of all persisted entities in the Application by creating their metadata dictionary
	 *
	 * @reload Reload the entire metadata dictionary
	 */
	array function getPersistedEntities( boolean reload = false ){
		try {
			// determine if the entity dictionary needs to be reloaded or created
			if ( arguments.reload OR arrayLen( variables.persistedEntities ) EQ 0 ) {
				// Read entity list from hibernate
				var entities = getAllEntityNames();

				// logging
				if ( logger.canInfo() ) {
					logger.info( "DataBoss Started and Loading Hibernate entity list: ", entities );
				}

				// loop through each entity and create/re-create dictionary
				for ( var entityName in entities ) {
					// Logging
					if ( logger.canDebug() ) {
						logger.debug( "Starting dictionary for: #entityName#" );
					}
					// Prepare the entity dictionary
					prepareDictionary( entityName );
				}

				// sort entities by display name
				variables.persistedEntities = structSort(
					variables.dictionary,
					"textNoCase",
					"ASC",
					"displayName"
				);
			}
			return variables.persistedEntities;
		} catch ( Any e ) {
			logger.error( "Error loading persisted entities dictionaries: #e.detail# #e.message#", e );
			return [];
		}
	}

	/* ----------------------------------- PRIVATE ----------------------------- */

	/**
	 * Talk to hibernate and get the entity names in the application
	 */
	private array function getAllEntityNames(){
		if ( server.coldfusion.productVersion.listFirst() >= 2018 ) {
			return ormGetSessionFactory().getMetaModel().getAllEntityNames();
		}
		return structKeyArray( ormGetSessionFactory().getAllClassMetadata() );
	}

	/**
	 * Get the PK name
	 *
	 * @hibernateMD The hibernate metadata class (See https://docs.jboss.org/hibernate/orm/3.5/api/org/hibernate/metadata/ClassMetadata.html)
	 */
	private function getPKInfo( required hibernateMD ){
		// Is this a simple key?
		if ( arguments.hibernateMD.hasIdentifierProperty() ) {
			return arguments.hibernateMD.getIdentifierPropertyName();
		}
		// Composite Keys?
		else if ( arguments.hibernateMD.getIdentifierType().isComponentType() ) {
			logger.warn( "Composite keys not supported by DataBoss" );

			// Do conversion to CF Array instead of java array, just in case
			return listToArray( arrayToList( arguments.hibernateMD.getIdentifierType().getPropertyNames() ) );
		}
	}

	/**
	 * Get an entity's class metadata
	 *
	 * @entityName The entity name
	 */
	private any function getClassMetadata( required entityName ){
		return variables.ormService.getEntityMetadata( arguments.entityName );
	}

	/**
	 * returns an array of persisted properties from an entity
	 *
	 * @entityName The entity name
	 */
	private array function getPersistedProperties( required entityName ){
		return getClassMetaData( arguments.entityName ).getPropertyNames();
	}

	/**
	 * Returns the hibernate property type object for a given property and entity
	 *
	 * @entityName   The entity Name
	 * @propertyName The property name
	 */
	private string function getPropertyType( required entityName, required propertyName ){
		return getClassMetaData( arguments.entityName ).getPropertyType( arguments.propertyName );
	}

	/**
	 * Construct a new normalized entity metadata entry
	 */
	private struct function getNewEntityMDEntry(){
		var entry = {
			name                 : "", // entity name
			displayName          : "", // display name for display purposes
			joinColumn           : "", // inheritance mapping column
			readOnly             : false, // can we do more than list?
			sortBy               : "", // The default sorting of this entry
			pk                   : { name : "", label : "" },
			properties           : [],
			hasCollections       : false,
			collections          : [],
			hasSingularRelations : false,
			singularRelations    : [],
			insertConstraints    : {},
			updateConstraints    : {}
		};

		return entry;
	}

	/**
	 * Construct a new normalized property metadata entry
	 */
	private struct function getNewPropertyMDEntry(){
		var pEntry = {
			dataType       : "string",
			name           : "",
			fieldType      : "",
			insert         : true,
			notNull        : false,
			update         : "",
			// DataBoss Metadata
			html           : "text",
			display        : true,
			displayCreate  : true,
			displayUpdate  : true,
			helpText       : "",
			labelText      : "",
			validate       : "",
			maxLength      : "",
			displayColumns : "",
			placeholder    : "",
			dateformat     : "",
			timeformat     : "",
			showDate       : true,
			showTime       : true,
			timeSeconds    : true,
			timeMeridian   : true,
			options        : "",
			optionsUDF     : ""
		};

		return pEntry;
	}

	/**
	 * Normalize the properties of an entity across the inheritance tree.
	 *
	 * @cfcMD      The cfc metadata
	 * @properties The properties structure
	 */
	private MetadataService function normalizeProperties( required any cfcMD, required struct properties ){
		var allProps = arguments.properties;

		// Verify we have properties at all in the metadata
		if ( NOT structKeyExists( arguments.cfcMD, "properties" ) ) {
			return this;
		}

		// Iterate and normalize
		for ( var x = 1; x <= arrayLen( arguments.cfcMD.properties ); x++ ) {
			var thisP = arguments.cfcMD.properties[ x ];

			// default field type to column
			if ( NOT structKeyExists( thisP, "fieldType" ) ) {
				thisP.fieldType = "column";
			}

			// Process persistence properties that are not PK's, timestamps, versions, forumulas or non persistable
			if (
				( structKeyExists( thisP, "persistent" ) AND NOT thisP.persistent )
				OR listFindNoCase( "timestamp,version", thisP.fieldType )
			) {
				continue;
			}

			// Create the basic normalized property Entry
			var pEntry = {
				name           : thisP.name,
				fieldType      : thisP.fieldType,
				html           : "text",
				display        : true,
				displayCreate  : true,
				displayUpdate  : true,
				validate       : "",
				helpText       : "",
				labelText      : "",
				maxLength      : "",
				displayColumns : "",
				singularName   : thisP.name,
				placeholder    : "",
				timeformat     : "",
				dateformat     : "",
				showDate       : true,
				showTime       : true,
				timeSeconds    : true,
				timeMeridian   : true,
				options        : "",
				optionsUDF     : ""
			};

			// Singular Name
			if ( structKeyExists( thisP, "singularName" ) ) {
				pEntry.singularName = thisP.singularName;
			}

			// DataBoss Metadata
			if ( structKeyExists( thisP, "length" ) ) {
				pEntry.maxlength = thisP.length;
			}
			if ( structKeyExists( thisP, "db_html" ) ) {
				pEntry.html = thisP.db_html;
			}
			if ( structKeyExists( thisP, "db_display" ) ) {
				pEntry.display = thisP.db_display;
			}
			if ( structKeyExists( thisP, "db_displayCreate" ) ) {
				pEntry.displayCreate = thisP.db_displayCreate;
			}
			if ( structKeyExists( thisP, "db_displayUpdate" ) ) {
				pEntry.displayUpdate = thisP.db_displayUpdate;
			}
			if ( structKeyExists( thisP, "db_validate" ) ) {
				pEntry.validate = thisP.db_validate;
			}
			if ( structKeyExists( thisP, "db_helpText" ) ) {
				pEntry.helpText = thisP.db_helpText;
			}
			if ( structKeyExists( thisP, "db_labelText" ) ) {
				pEntry.labelText = thisP.db_labelText;
			}
			if ( structKeyExists( thisP, "db_maxLength" ) ) {
				pEntry.maxlength = thisP.db_maxLength;
			}
			if ( structKeyExists( thisP, "db_displayColumns" ) ) {
				pEntry.displayColumns = thisP.db_displayColumns;
			}
			if ( structKeyExists( thisP, "db_placeholder" ) ) {
				pEntry.placeholder = thisP.db_placeholder;
			}
			if ( structKeyExists( thisP, "db_timeformat" ) ) {
				pEntry.timeformat = thisP.db_timeformat;
			}
			if ( structKeyExists( thisP, "db_dateformat" ) ) {
				pEntry.dateformat = thisP.db_dateformat;
			}
			if ( structKeyExists( thisP, "db_showDate" ) ) {
				pEntry.showDate = thisP.db_showDate;
			}
			if ( structKeyExists( thisP, "db_showTime" ) ) {
				pEntry.showTime = thisP.db_showTime;
			}
			if ( structKeyExists( thisP, "db_timeSeconds" ) ) {
				pEntry.timeSeconds = thisP.db_timeSeconds;
			}
			if ( structKeyExists( thisP, "db_timeMeridian" ) ) {
				pEntry.timeMeridian = thisP.db_timeMeridian;
			}
			if ( structKeyExists( thisP, "db_options" ) ) {
				pEntry.options = thisP.db_options;
			}
			if ( structKeyExists( thisP, "db_optionsUDF" ) ) {
				pEntry.optionsUDF = thisP.db_optionsUDF;
			}
			// Add to normalized prop collection
			allProps[ pEntry.name ] = pEntry;
		}
		// end for loop

		// Extends recursion?
		if ( structKeyExists( arguments.cfcMD, "extends" ) ) {
			// Recursive normalization
			normalizeProperties( arguments.cfcMD.extends, allProps );
		}

		return this;
	}
	// end of normalizeProperties()

}
