/**
 ********************************************************************************
 * Copyright 2012 Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * ---
 * Display Helper when dealing with complicated relationships
 * ----------------------------------------------------------------------->
 *
 * @author Luis Majano, Brad Wood
 */
component singleton {

	/**
	 * Build display columns according to entity and relations
	 *
	 * @entity                    The entity displaying
	 * @relatedPropertyDictionary The related property dictionary to use
	 * @relatedEntity             The related entity to display if any
	 *
	 * @return Constructed column string
	 */
	function buildDisplayColumns(
		required entity,
		required relatedPropertyDictionary,
		relatedEntity
	){
		var relAlias          = arguments.relatedPropertyDictionary.alias;
		var relDisplayColumns = arguments.relatedPropertyDictionary.displayColumns;
		var relPK             = arguments.relatedPropertyDictionary.pk.name;

		var thisValue = "<null>";

		// Check to see if we received a related entity instance
		if ( !structKeyExists( arguments, "relatedEntity" ) ) {
			// If relationship is empty, just return null
			if ( !evaluate( "arguments.entity.has#relAlias#()" ) ) {
				return thisValue;
			}

			// If not, get it from the base entity
			arguments.relatedEntity = evaluate( "arguments.entity.get#relAlias#()" );
		}

		// Check if no DisplayColumns, else use PK
		if ( !len( relDisplayColumns ) ) {
			return evaluate( "arguments.relatedEntity.get#relPK#()" );
		}

		// We have displayColumns, so let's build them up in this array!
		var aThisValue = [];

		// For each column...
		for ( var col in listToArray( relDisplayColumns ) ) {
			// This will be our moving target.  Once the while loop below is done, it should hold the final value
			var thisColumnData = arguments.relatedEntity;

			// Each column *may* be a dot-delimited list to allow reference to "deep" properties
			// i.e. db_displayColumns="supervisor.company.name";
			for ( var colPart in listToArray( col, "." ) ) {
				thisColumnData = evaluate( "thisColumnData.get#colPart#()" );

				// If we've reached a dead end, stop
				if ( isNull( thisColumnData ) ) {
					thisColumnData = "<null>";
					// Break out of this column, but the outer loop will keep going on the next column
					break;
				}
			}

			// Add this column to the array
			arrayAppend( aThisValue, thisColumnData );
		}

		// Turn the array of values back into a list
		thisValue = arrayToList( aThisValue, ", " );

		// Nullable check
		if ( isNull( thisValue ) ) {
			thisValue = "<null>";
		}

		return thisValue;
	}

}
