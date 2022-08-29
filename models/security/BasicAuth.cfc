/**
 * Copyright 2012 Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * ---
 * Provides basic authentication tot he system
 * ----------------------------------------------------------------------->
 *
 * @author Luis Majano
 */
component {

	// DI
	property name="settings"        inject="coldbox:modulesettings:databoss";
	property name="securityService" inject="id:securityService@databoss";
	property name="logger"          inject="logbox:logger:databoss";

	/**
	 * Configure interceptor
	 */
	void function configure(){
	}

	/**
	 * Process security on pre process
	 */
	function preProcess( event, struct interceptData ) eventPattern="^databoss\:"{
		// Enabled?
		if ( !settings.basicauthentication.enabled ) {
			return;
		}

		// Verify Incoming Headers to see if we are authorizing already or we are already Authorized
		if ( !securityService.isLoggedIn() OR len( event.getHTTPHeader( "Authorization", "" ) ) ) {
			// Verify incoming authorization
			var credentials = event.getHTTPBasicCredentials();
			if ( securityService.authorize( credentials.username, credentials.password ) ) {
				// we are secured woot woot!
				return;
			};

			// Not secure!
			event.setHTTPHeader(
				name  = "WWW-Authenticate",
				value = "basic realm=""#getResource( "db_access_credentials@db" )#:"""
			);

			// secured content data and skip event execution
			event
				.renderData(
					data       = "<h1>#getResource( "db_access_denied@db" )#</h1>",
					statusCode = "401",
					statusText = "#getResource( "db_access_denied@db" )#"
				)
				.noExecution();
		}
	}

}
