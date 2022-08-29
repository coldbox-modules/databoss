<!---
********************************************************************************
Copyright 2012 Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
--->
<cfoutput>
<script type="text/javascript">
$(document).ready(function() {
	// global IDs
	$entityTable = $("##entityTable");
	$entityForm  = $("##entityForm");
	$loaderBar   = $("##loaderBar");

	// call the tablesorter plugin
	$entityTable.tablesorter();
	$("##entityFilter").keyup(function(){
		$.uiTableFilter( $entityTable, this.value );
	})
	// toggle all
	$('##checkAllAuto').click(function(){
		$("input[type='checkbox']").prop('checked', $('##checkAllAuto').is(':checked') );
	})

});
function showFullCellContent(id){
	$("##cell_"+id).hide();
	$("##cellfull_"+id).fadeIn();
}
function hideFullCellContent(id){
	$("##cellfull_"+id).hide();
	$("##cell_"+id).fadeIn();
}
</script>
</cfoutput>