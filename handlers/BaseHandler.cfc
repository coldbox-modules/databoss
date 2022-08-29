/**
 * Copyright 2012 Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * @author Luis Majano
 * ---
 * Base Databoss Handler
 */
component{

	// Dependencies
	property name="entityService"    	inject="id:entityService@databoss";
	property name="metadataService"  	inject="id:metadataService@databoss";
	property name="entityDisplayHelper" inject="id:entityDisplayHelper@databoss";
	property name="i18n"			 	inject="i18n@cbi18n";
	property name="logger"				inject="logbox:logger:databoss";
	property name="moduleSettings"		inject="coldbox:modulesettings:databoss";
	property name="paging"				inject="id:paging@databoss";
	property name="htmlHelper"			inject="HTMLHelper@coldbox";

	/**
	 * preHandler
	 */
	function preHandler( event, rc, prc, action ){
		// Param global format values
		event.paramValue( "format", "html" );
		event.paramValue( "rURL", "" );

		// put display helper in prc scope
		prc.entityDisplayHelper = entityDisplayHelper;

		// Global Exit Handlers
		prc.xehEntityList 		= "databoss/entity";
		prc.xehDataboss			= "databoss";

		// Global Actions
		prc.xehDictionaryClean  = "databoss/main/cleanDictionary";
		prc.xehReloadORM		= "databoss/main/reloadORM";
		prc.xehReloadApp		= "databoss/main/reloadApp";

		// Get correct paging object if in module mode
		prc.oPaging = variables.paging;
		// Determine correct module root of operation
		prc.modRoot = event.getModuleRoot( "databoss" ) & "/";

		// check for locale changes
		if( event.valueExists( 'locale' ) ){
			// validate locale
			if( arrayFindNoCase( moduleSettings.supportedLanguages, rc.locale ) gt 0 ){
				i18n.setFwLocale( rc.locale );
			}
		}
		prc.userLocale = i18n.getFwLocale();

		// Load System Entities
		prc.systemEntities = metadataService.getPersistedEntities()
			.filter( function( item ){
				// Are we using only lists?
				return ( !moduleSettings.entitiesOnly.len() OR moduleSettings.entitiesOnly.findNoCase( item ) );
			} )
			.filter( function( item ){
				// Filter out exceptions
				return ( moduleSettings.entitiesExcept.findNoCase( item ) == 0 );
			} );

		// Load System Dictionary
		prc.systemDictionary 	= metadataService.getDictionary();

		// Only load assets for HTML
		if( rc.format eq "html" ){
			/***************************** START PLACEHOLDERS *****************************/
			//injector:css//
			addAsset( "#prc.modRoot#includes/css/03825f5a.databoss.min.css ");
			//endinjector//
			//injector:js//
			addAsset( "#prc.modRoot#includes/js/19d42eab.databoss.min.js ");
			//endinjector//
			/***************************** END PLACEHOLDERS *****************************/
		}
	}

}