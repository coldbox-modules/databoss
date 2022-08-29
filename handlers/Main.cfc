/**
 * Copyright 2012 Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * ---
 * Manage the entity listings
 *
 * @author Luis Majano
 */
component extends="BaseHandler" {

	/**
	 * Visualize the managed entities
	 */
	function index( event, rc, prc ){
		event.setView( "main/index" );
	}

	/**
	 * reload the ORM
	 */
	function reloadORM( event, rc, prc ){
		var nextEvent = event.getValue( "returnURL", "databoss" );

		ormReload();
		metadataService.cleanDictionary();
		flash.put( "notice", { type : "info", message : $r( "db_orm_reloaded@db" ) } );

		relocate( nextEvent );
	}

	/**
	 * reload the Application
	 */
	function reloadAPP( event, rc, prc ){
		var nextEvent = event.getValue( "returnURL", "databoss" );

		// Ran through post process
		flash.put( "notice", { type : "info", message : $r( "db_app_reloaded@db" ) } );

		relocate( nextEvent );
	}

	/**
	 * Cleans the entire metadata dictionary
	 */
	function cleanDictionary( event, rc, prc ){
		var nextEvent = event.getValue( "returnURL", "databoss" );

		metadataService.cleanDictionary();
		flash.put(
			"notice",
			{
				type    : "info",
				message : $r( "db_dictionary_cleaned@db" )
			}
		);

		relocate( nextEvent );
	}

}
