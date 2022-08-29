<cfoutput>
<script>
$(function() {
	// activate all drop downs
	$( ".dropdown-toggle" ).dropdown();
	// Tooltips
	 $( "[rel=tooltip]" ).tooltip();
	 // flicker messages
	var t = setTimeout( "toggleFlickers()", 15000 );
})
function toggleFlickers(){
	$( ".flickerMessages" ).slideToggle();
}
function updateDTField( dtField ){
	var fieldID = "##" + dtField;
	if( $.ready() ){
		var d = $( fieldID + "-dField" ).data('datepicker').date;

		// The date could be in any format, so extract the peices without any timezone offsets
		var yyyy = d.getUTCFullYear().toString();                                    
		var mm = (d.getUTCMonth()+1).toString(); // getMonth() is zero-based         
		var dd  = d.getUTCDate().toString();             
		                    
		// Build a date to submit with standard format so we don't confuse SQL when we save
		var formattedDate = yyyy + '-' + (mm[1]?mm:"0"+mm[0]) + '-' + (dd[1]?dd:"0"+dd[0]);
		
		$( fieldID ).val( formattedDate + ' ' + $( fieldID + "-tField" ).val()  );
	}
}
</script>
</cfoutput>