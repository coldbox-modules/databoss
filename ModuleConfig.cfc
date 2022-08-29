/**
 * Ortus DataBoss
 * Copyright 2012 Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * DataBoss Module Configuration
 */
component {

	// Module Properties
	this.title              = "Ortus DataBoss";
	this.author             = "Ortus Solutions, Corp";
	this.webURL             = "https://www.ortussolutions.com";
	this.description        = "Dynamic Administrator: Manage CFML ORM entities the DataBoss Way!";
	this.version            = "@build.version@+@build.number@";
	this.viewParentLookup   = true;
	this.layoutParentLookup = true;
	this.entryPoint         = "databoss";
	this.cfmapping          = "databoss";
	this.namespace          = "databoss";
	this.dependencies       = [ "cborm" ];

	/**
	 * Configure the Module
	 */
	function configure(){
		settings = {
			// DataBoss Version
			version             : this.version,
			// Pagination
			pagingMaxRows       : "20",
			pagingBandGap       : "5",
			// Localization Settings
			showLanguageOptions : true,
			supportedLanguages  : [
				"en_US",
				"es_CO",
				"de_DE",
				"fr_FR",
				"pt_BR",
				"it_IT"
			],
			defaultLocale       : "en_US",
			// Listing Max Chars
			listingMaxChars     : 100,
			// Show Dictionary Dump
			debugMode           : false,
			// Show Global Actions
			showGlobalActions   : true,
			// Show Logo
			showLogo            : true,
			// Show About
			showAbout           : true,
			// JSONP CallBack
			jsonpcallback       : "",
			// Basic Auth
			basicAuthentication : {
				enabled  : false,
				username : "admin",
				password : "databoss"
			},
			// Logging
			logging        : { enabled : true, levelMin : "FATAL", levelMax : "INFO" },
			// Entity Exclusions: A list of entity names to exclude from management
			entitiesExcept : [],
			// Entity Inclusions: A list of entity names that we will manage ONLY. If emtpy, we manage all.
			entitiesOnly   : []
		};

		// Layouts
		layoutSettings = { defaultLayout : "DataBoss.cfm" };

		// Interceptor Events
		interceptorSettings = {
			// ContentBox UI Custom Events, you can add your own if you like to!
			customInterceptionPoints : [
				// UI Events
				"db_header_logo",
				"db_leftnavbar_start",
				"db_leftnavbar_end",
				"db_rightnavbar_start",
				"db_rightnavbar_end",
				"db_afterBodyStart",
				"db_afterBodyEnd",
				"db_afterHeadStart",
				"db_afterHeadEnd"
			]
		};

		// Interceptors
		interceptors = [
			{
				name  : "databoss@basicAuth",
				class : "#moduleMapping#.models.security.BasicAuth"
			}
		];

		// i18n & Localization
		i18n = {
			resourceBundles    : { "db" : "#moduleMapping#/includes/i18n/main" },
			defaultLocale      : settings.defaultLocale,
			localeStorage      : "cookie",
			unknownTranslation : "**NOT FOUND**"
		};
	}

	/**
	 * Executes when the module loads
	 */
	function onLoad(){
	}

	/************************************** COLDBOX EVENTS *********************************************/

	/**
	 * Executes when the process finalizes
	 */
	function postProcess( event, interceptData ){
		// do restarts if sent via console.
		if ( event.getCurrentEvent() eq "databoss:databoss.reloadApp" ) {
			applicationStop();
		}
	}

}
