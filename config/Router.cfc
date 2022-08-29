component {

	function configure(){
		// Entity Editor
		route( pattern = "/entity/:entity/id/:id", target = "databoss.editor" );

		// Listing Pagination
		route( pattern = "/entity/:entity/page/:page", target = "databoss.index" );

		// Listing Exports
		route( pattern = "/entity/:entity/export/:format", target = "databoss.index" );

		// Listing Show All Records
		route( "/entity/:entity/showAll" ).rc( "showAll", true ).to( "databoss.index" );

		// Entity Actions
		route( "/entity/:entity/:action" ).toHandler( "databoss" );

		// Listing
		route( pattern = "/entity/:entity", target = "databoss.index" );

		// Main Actions
		route( "/main/:action" ).toHandler( "Main" );

		// FallBack
		route( "/:action" ).toHandler( "databoss" );

		// Home Page
		route( pattern = "/", target = "main.index" );
	}

}
