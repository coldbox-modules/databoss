/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 */
component {

	// Module Properties
	this.title 				= "Databoss";
	this.author 			= "Ortus Solutions";
	this.webURL 			= "https://www.ortussolutions.com";
	this.description 		= "A Dynamic Administrator for ORM";
	this.version 			= "@build.version@+@build.number@";

	// Model Namespace
	this.modelNamespace		= "databoss";

	// CF Mapping
	this.cfmapping			= "databoss";

	// Dependencies
	this.dependencies 		= [];

	/**
	 * Configure Module
	 */
	function configure(){
		settings = {

		};
	}

	/**
	 * Fired when the module is registered and activated.
	 */
	function onLoad(){

	}

	/**
	 * Fired when the module is unregistered and unloaded
	 */
	function onUnload(){

	}

}
