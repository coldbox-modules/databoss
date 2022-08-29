/**
 * Copyright 2012 Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * ---
 * Provides authorization for basic auth
 * ----------------------------------------------------------------------->
 *
 * @author Luis Majano
 */
component accessors="true" singleton {

	// Dependencies
	property name="sessionStorage" inject="sessionStorage@cbstorages";
	property name="settings"       inject="coldbox:modulesettings:databoss";
	property name="logger"         inject="logbox:logger:databoss";

	/**
	 * Constructor
	 */
	SecurityService function init(){
		return this;
	}

	/**
	 * Authorize with basic auth
	 *
	 * @username The username to verify
	 * @password The password to verify
	 */
	function authorize( required username, required password ){
		// Validate Credentials
		if (
			settings.basicAuthentication.username eq arguments.username AND
			settings.basicAuthentication.password eq arguments.password
		) {
			// Set simple validation
			sessionStorage.setVar( "userAuthorized", true );
		}

		return isLoggedIn();
	}

	/**
	 * Checks if user already logged in or not.
	 */
	boolean function isLoggedIn(){
		return ( sessionStorage.getVar( "userAuthorized", "false" ) ? true : false );
	}

}
