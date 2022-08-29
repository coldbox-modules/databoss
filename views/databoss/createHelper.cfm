<!---
********************************************************************************
Copyright 2012 Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
--->
<cfoutput>
<script>
$(function() {
	// Global Variables
	$entityForm = $( "##entityForm" );
	// Activate Editor
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
	// Date pickers
	$( ".datepicker" ).datepicker({
		autoclose : true
	});
	// Time Pickers
	$( ".clockpicker" ).clockpicker({
		default		: '',
		vibrate		: true,
		donetext	: 'Ok'
	});
	// Form actions
	$entityForm.submit(function() {
		$entityForm.find( "##buttonBar" ).slideUp( "fast" );
		$entityForm.find( "##loaderBar" ).fadeIn( "slow" );
	});
});
</script>
</cfoutput>