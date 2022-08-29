/**
 * Copyright 2012 Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * ---
 * Main Databoss Handler
 *
 * @author Luis Majano
 */
component extends="BaseHandler" {

	/**
	 * Executes before all handler actions
	 */
	any function preHandler( event, rc, prc, action, eventArguments ){
		super.preHandler( argumentCollection = arguments );

		// Cleanup
		rc.entity     = urlDecode( rc.entity );
		rc.safeEntity = urlEncodedFormat( rc.entity );
	}

	/**
	 * display listings for entities
	 */
	function index( event, rc, prc ){
		// params
		event
			.paramValue( "showAll", false )
			.paramValue( "includes", "" )
			.paramValue( "excludes", "" )
			.paramValue( "ignoreDefaults", false )
			.paramValue( "entity", "" );

		// Verify incoming entity
		if ( !prc.systemEntities.findNoCase( rc.entity ) ) {
			relocate( prc.xehDataboss );
		}

		// exit handlers
		prc.xehEntityDelete = "databoss/doDelete";

		// Get Entity's Meta Data Dictionary
		prc.mdDictionary = metadataService.getDictionaryEntry( rc.entity );

		// Calculate the start row
		prc.pagingBoundaries = prc.oPaging.getBoundaries();
		prc.pagingLink       = event.buildLink( prc.xehEntityList ) & "/#rc.safeEntity#/page/@page@";

		// Get entity listing
		prc.listingCount = entityService.count( entityName = rc.entity );
		prc.aListing     = entityService.list(
			entityName = rc.entity,
			sortOrder  = prc.mdDictionary.sortBy,
			offset     = ( rc.showAll ? 0 : prc.pagingBoundaries.startRow ),
			max        = ( rc.showAll ? 0 : prc.oPaging.getPagingMaxRows() ),
			asQuery    = false
		);

		// Rendering Formats
		prc.export = false;
		switch ( rc.format ) {
			case "json":
			case "xml":
			case "wddx":
			case "jsonp": {
				event.renderData(
					type = rc.format,
					data = prc.aListing.map( function( item ){
						return item.getMemento(
							includes       = rc.includes,
							excludes       = rc.excludes,
							ignoreDefaults = rc.ignoreDefaults
						);
					} ),
					xmlRootName  = "#rc.entity#",
					jsonCallback = moduleSettings.jsonpcallback
				);
				break;
			}
			case "pdf": {
				prc.export = true;
				event.renderData( type = "pdf", data = renderView( view = "databoss/index", module = "databoss" ) );
				break;
			}
			default: {
				// Set view to render
				event.setView( "databoss/index" );
			}
		}
	}

	/**
	 * Delete an entity from the system
	 */
	function doDelete( event, rc, prc ){
		// Check that listing sent in
		if ( len( event.getTrimValue( "entityID", "" ) ) ) {
			var errors = [];
			// Loop through listing and delete objects
			rc.entityID
				.listToArray()
				.each( function( item ){
					try {
						entityService.delete( entityService.get( entityName = rc.entity, id = item ) );
					} catch ( any e ) {
						errors.append( e.message & e.detail );
						log.error( "Error deleting entity: #rc.safeEntity#(#item#) : #e.message# #e.detail#", e );
					}
				} );

			// Message
			if ( arrayLen( errors ) eq 0 ) {
				flash.put(
					"notice",
					{
						type    : "success",
						message : getResource( "db_record_deletion_complete@db" )
					}
				);
			} else {
				// create customized error message
				flash.put(
					"notice",
					{
						type    : "danger",
						message : getResource( "db_record_deletion_failed@db" ) & htmlHelper.ul( errors )
					}
				);
			}
		} else {
			// Message
			flash.put(
				"notice",
				{
					type    : "warning",
					message : getResource( "db_record_deletion_no_records@db" )
				}
			);
		}

		// If the user came from somewhere specific...
		if ( len( rc.rURL ) ) {
			// ...go back there.
			relocate( event = rc.rURL );
		} else {
			// Otherwise, relocate back to listing
			relocate( event = "databoss.entity", queryString = rc.safeEntity );
		}
	}

	/**
	 * Create the creation form
	 */
	function create( event, rc, prc ){
		// Get Entity's md Dictionary
		prc.mdDictionary = metadataService.getDictionaryEntry( rc.entity );
		// Get Default Entity
		prc.oEntity      = entityService.new( prc.mdDictionary.name );
		// Check Singular Relations
		if ( prc.mdDictionary.hasSingularRelations ) {
			// Get Entity Listings
			for ( var thisRelation in prc.mdDictionary.singularRelations ) {
				// get source entity metadata dictionary
				var thisRelationMD        = metadataService.getDictionaryEntry( thisRelation.sourceEntity );
				// get a listing
				prc[ thisRelation.alias ] = entityService.list(
					entityName = thisRelation.sourceEntity,
					sortOrder  = thisRelationMD.sortBy,
					asQuery    = false
				);
			}
		}
		// Set view.
		event.setView( "databoss/create" );
	}

	/**
	 * doCreate
	 */
	function doCreate( event, rc, prc ){
		// Get Entity's md Dictionary
		prc.mdDictionary = metadataService.getDictionaryEntry( rc.entity );
		// Get a new entity to create
		var	oEntity      = entityService.new( prc.mdDictionary.name );

		// Validate entity if possible via ColdBox validation
		if (
			!coldboxValidation(
				oEntity,
				"create",
				arguments.event,
				arguments.rc,
				arguments.prc
			)
		) {
			return;
		}

		// Populate it with RC data
		populateModel( oEntity );

		// Loop Through relations and inflate them (Many to One)
		for ( var i = 1; i lte arrayLen( prc.mdDictionary.singularRelations ); i++ ) {
			// check if we have the alias
			if (
				structKeyExists( rc, "fk_" & prc.mdDictionary.singularRelations[ i ].alias )
				AND len( rc[ "fk_" & prc.mdDictionary.singularRelations[ i ].alias ] ) GT 0
			) {
				var tmpEntity = entityService.get(
					entityName = prc.mdDictionary.singularRelations[ i ].sourceEntity,
					id         = rc[ "fk_" & prc.mdDictionary.singularRelations[ i ].alias ]
				);

				// add the relationship to the entity
				invoke(
					oEntity,
					"set#prc.mdDictionary.singularRelations[ i ].alias#",
					[ tmpEntity ]
				);
			}
		}

		// Save entity
		entityService.save( oEntity );

		// If the user came from somewhere specific...
		if ( len( rc.rURL ) ) {
			// ...go back there.
			relocate( event = rc.rURL );
		} else {
			// Otherwise, relocate back to listing
			relocate( event = prc.xehEntityList, queryString = "#rc.entity#" );
		}
	}

	/**
	 * The entity editor
	 */
	function editor( event, rc, prc ){
		// Params
		event
			.paramValue( "includes", "" )
			.paramValue( "excludes", "" )
			.paramValue( "ignoreDefaults", false );
		// exit handlers
		prc.xehEntityDelete = "databoss/doDelete";
		// Get Entity's md Dictionary
		prc.mdDictionary    = metadataService.getDictionaryEntry( rc.entity );
		// Load the entity requested to edit by ID
		prc.oEntity         = entityService.get( rc.entity, rc.id );
		// Get the primary key
		prc.pkValue         = invoke( prc.oEntity, "get#prc.mdDictionary.pk.name#" );
		// Check for singular relations
		if ( prc.mdDictionary.hasSingularRelations ) {
			// Get Entity Listings
			for ( var thisRelation in prc.mdDictionary.singularRelations ) {
				// get source entity metadata dictionary
				var thisRelationMD        = metadataService.getDictionaryEntry( thisRelation.sourceEntity );
				// get a listing
				prc[ thisRelation.alias ] = entityService.list(
					entityName = thisRelation.sourceEntity,
					sortOrder  = thisRelationMD.sortBy,
					asQuery    = false
				);
			}
		}

		// Check for collection relations
		if ( prc.mdDictionary.hasCollections ) {
			// Get Entity Listings, TODO: add sorts
			for ( var i = 1; i lte arrayLen( prc.mdDictionary.collections ); i++ ) {
				var tmpAlias                  = prc.mdDictionary.collections[ i ].alias;
				// store the collection dictionary
				prc[ "#tmpAlias#Dictionary" ] = metadataService.getDictionaryEntry(
					prc.mdDictionary.collections[ i ].sourceEntity
				);
				// store lookup queries for additions
				prc[ "#tmpAlias#" ] = entityService.list(
					entityName = prc.mdDictionary.collections[ i ].sourceEntity,
					sortOrder  = prc[ "#tmpAlias#Dictionary" ].sortBy,
					asQuery    = false
				);
				// store the actual array of entities
				prc[ "#tmpAlias#Array" ] = invoke( prc.oEntity, "get#tmpAlias#" );
			}
		}

		// Rendering + Exports
		prc.export = false;
		switch ( rc.format ) {
			case "json":
			case "xml":
			case "wddx":
			case "jsonp": {
				event.renderData(
					type = rc.format,
					data = prc.oEntity.getMemento(
						includes       = rc.includes,
						excludes       = rc.excludes,
						ignoreDefaults = rc.ignoreDefaults
					),
					xmlRootName  = "#rc.entity#",
					jsonCallback = moduleSettings.jsonpcallback
				);
				break;
			}

			case "pdf": {
				prc.export = true;
				event.renderData(
					type = "pdf",
					data = renderView( view = "databoss/editor", module = "databoss" )
				);
				break;
			}

			default: {
				// Set view to render
				event.setView( "databoss/editor" );
			}
		}
	}

	/**
	 * doUpdate
	 */
	function doUpdate( event, rc, prc ){
		// Get Entity's md Dictionary
		prc.mdDictionary = metadataService.getDictionaryEntry( rc.entity );
		// Get the entity to update
		var oEntity      = entityService.get( prc.mdDictionary.name, rc.id );
		// Validate entity if possible via ColdBox validation
		if (
			!coldboxValidation(
				oEntity,
				"update",
				arguments.event,
				arguments.rc,
				arguments.prc
			)
		) {
			return;
		}
		// Populate it with RC data
		populateModel( oEntity );
		// Loop Through relations
		for ( var i = 1; i lte arrayLen( prc.mdDictionary.singularRelations ); i++ ) {
			// verify if fk exists in incoming rc
			if (
				structKeyExists( rc, "fk_" & prc.mdDictionary.singularRelations[ i ].alias )
				AND len( rc[ "fk_" & prc.mdDictionary.singularRelations[ i ].alias ] ) GT 0
			) {
				// Is this null?
				if ( rc[ "fk_" & prc.mdDictionary.singularRelations[ i ].alias ] == "null" ) {
					invoke(
						oEntity,
						"set#prc.mdDictionary.singularRelations[ i ].alias#",
						[ javacast( "null", "" ) ]
					);
					continue;
				}
				// get tmp relation entity
				var	tmpEntity = entityService.get(
					entityName = prc.mdDictionary.singularRelations[ i ].sourceEntity,
					id         = rc[ "fk_" & prc.mdDictionary.singularRelations[ i ].alias ]
				);
				// add the tmpTO to oLookup
				invoke(
					oEntity,
					"set#prc.mdDictionary.singularRelations[ i ].alias#",
					[ tmpEntity ]
				);
			}
		}
		// Tell service to save object
		entityService.save( oEntity );

		// If the user came from somewhere specific...
		if ( len( rc.rURL ) ) {
			// ...go back there.
			relocate( event = rc.rURL );
		} else {
			// Otherwise, relocate back to listing
			relocate( event = prc.xehEntityList, queryString = "#rc.entity#" );
		}
	}

	/**
	 * doUpdateRelation
	 */
	function doUpdateRelation( event, rc, prc ){
		// param values
		var oRelation = oEntity = mdDictionary = relationDictionary = relationSingularName = "";

		// Incoming Args: entity, entityID, addrelation[boolean], relationSource, relationAlias

		// Get Source Entity's md Dictionary
		rc.mdDictionary = metadataService.getDictionaryEntry( rc.entity );
		// Get the entity to update
		oEntity         = entityService.get( rc.mdDictionary.name, rc.entityID );
		// Get the relation singular name
		for ( var rel in rc.mdDictionary.collections ) {
			if ( rc.relationSource eq rel.sourceEntity ) {
				relationSingularName = rel.singularName;
			}
		}

		// Adding or Deleting
		if ( rc.addrelation ) {
			// Get the relation object
			oRelation = entityService.get( rc.relationSource, rc[ "collection_#rc.relationAlias#" ] );

			// Check if it is already in the collection
			if (
				NOT invoke(
					oEntity,
					"has#relationSingularName#",
					[ oRelation ]
				)
			) {
				// Add Relation to parent
				invoke(
					oEntity,
					"add#relationSingularName#",
					[ oRelation ]
				);
			}
		} else if ( structKeyExists( rc, "collection_#rc.relationAlias#_id" ) ) {
			var deleteRelationList = rc[ "collection_#rc.relationAlias#_id" ];

			// Remove Relations
			for ( var i = 1; i lte listLen( deleteRelationList ); i++ ) {
				// Get Relation Object
				oRelation = entityService.get( rc.relationSource, listGetAt( deleteRElationList, i ) );
				// Remove Relation from parent
				invoke(
					oEntity,
					"remove#relationSingularName#",
					[ oRelation ]
				);
			}
		}

		// Persist entity
		entityService.save( oEntity );

		// Relocate back to edit
		relocate( event = "databoss.entity.#rc.entity#", queryString = "id=#rc.entityID#/collection/true" );
	}

	/************************************** PRIVATE *********************************************/

	/**
	 * ColdBox Validation
	 *
	 * @entity The entity to validate
	 * @type   Type of validation "create or update"
	 * @event 
	 * @rc    
	 * @prc   
	 */
	private boolean function coldboxValidation(
		required oEntity,
		required type,
		required event,
		required rc,
		required prc
	){
		var valid       = false;
		var constraints = arguments.prc.mdDictionary.insertConstraints;

		// ColdBox direct ORM constraints validation
		if ( structKeyExists( arguments.oEntity, "constraints" ) ) {
			constraints = arguments.oEntity.constraints;
		}

		// Validate RC
		var validationResults = validateModel( target = arguments.rc, constraints = constraints );
		if ( validationResults.hasErrors() ) {
			// MB for error
			flash.put(
				"notice",
				{
					type    : "danger",
					message : htmlHelper.ul( validationResults.getAllErrors() )
				}
			);
		} else {
			valid = true;
		}

		// execute method to show back
		if ( !valid ) {
			if ( arguments.type eq "create" ) {
				create( arguments.event, arguments.rc, arguments.prc );
			} else {
				editor( arguments.event, arguments.rc, arguments.prc );
			}
		}

		return valid;
	}


	/**
	 * Get the sorted entities
	 */
	private Array function getSortedEntities( entities ){
		var sortedEntities = "";

		sortedEntities = structKeyArray( arguments.entities );
		arraySort( sortedEntities, "text" );

		return sortedEntities;
	}

	/**
	 * Conver the query to a struct
	 *
	 * @target The query
	 */
	private function queryToStruct( required target ){
		listToArray( arguments.target.columnlist ).reduce( function( result, column ){
			result[ column ] = target[ column ][ 1 ];
			return result;
		}, {} );
	}

}
