<!---
********************************************************************************
Copyright 2012 Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
--->
<cfoutput>
<script type="text/javascript" language="javascript">
$( document ).ready(function() {
	// Global Variables
	$entityDeleteForm 	= $( "##entityDeleteForm" );
	$entityForm 		= $( "##entityForm" );
	$loaderBar   		= $( "##loaderBar" );
	// Activate RTE
	$( ".rte-zone" ).wysihtml5( {
		toolbar : {
			"font-styles" 	: true,
			"html" 			: true,
			"lists" 		: true,
			"emphasis"		: true,
			"link"			: true, 
			"image"			: true, 
			"color"			: true,
			"blockquote"	: true,
			"size"			: "small",
			"fa"			: true
		} 
	} );
	// DatePickers
	$( ".datepicker" ).datepicker({
    	autoclose : true
	});
	// Time Pickers
	$( ".clockpicker" ).clockpicker({
		default		: '',
		vibrate		: true,
		donetext	: 'Ok'
	});
	// Show Collections
	<cfif prc.mdDictionary.hasCollections>
		<cfloop from="1" to="#arrayLen(prc.mdDictionary.collections)#" index="relIndex">
		// call the tablesorter plugin
		$( "##collection_#prc.mdDictionary.collections[relIndex].alias#_table" ).tablesorter();
		</cfloop>
	</cfif>
	<cfif event.valueExists( "collection" )>
		$( "##contentTabs a:last" ).tab( "show" );
	</cfif>
	// form loaders
	$entityForm.submit(function() {
		$entityForm.find( "##buttonBar" ).slideUp( "fast" );
		$entityForm.find( "##loaderBar" ).fadeIn( "slow" );
	});
});

function submitCollection(relation,addRelation){
	//Add Relation Check
	var txtAddRelation = $( "##add" + relation + "Form > input[id='addRelation']" );
	txtAddRelation.val(addRelation);
	$( "##_buttonbar_" + relation ).slideUp( "fast" );
	$( "##_loader_" + relation ).fadeIn( "slow" );
	$( "##add" + relation + "Form" ).submit();
}

function confirmDelete( entity, entityID ){
	if ( confirm( "#getResource('db_record_deletion_confirmation@db')#" ) ){
		deleteRecord( entity, entityID );
	}
}

function deleteRecord( entity, entityID ){
	$loaderBar.fadeIn();

	// Set the entity to be deleted
	$( "##delete_entity" ).val( entity );
	$( "##delete_entityID" ).val( entityID );

	//Submit Form
	$entityDeleteForm.submit();
}
</script>
</cfoutput>