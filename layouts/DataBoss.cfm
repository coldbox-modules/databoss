<!---
********************************************************************************
Copyright 2012 Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
--->
<!DOCTYPE html>
<html>
<cfoutput>
<head>
	<!---Event --->
	#announceInterception( "db_afterHeadStart" )#
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="description" content="#getResource( 'db_site_meta_description@db' )#" />
	<meta name="author" content="Ortus Solutions, Corp (www.ortussolutions.com)" />
	<title>Ortus DataBoss</title>
	<cfoutput>
	<!--- Base HREF --->
	<base href="#event.getHTMLBaseURL()#">
	<!--- Favicon and shortcut images --->
	<link rel="shortcut icon" href="#prc.modRoot#includes/images/favicon.ico" >
	<link rel="icon" type="image/gif" href="#prc.modRoot#includes/images/favicon.ico" >
	<!---Event --->
	#announceInterception( "db_beforeHeadEnd" )#
	</cfoutput>
</head>
<body data-offset="50">
	<!---Event --->
	#announceInterception( "db_afterBodyStart" )#

	<!---Container And Views --->
	<div class="container">#renderView()#</div>

	<!---Debug mode --->
	<cfif getModuleSettings( "databoss" ).debugMode>
		<cfdump var="#getModel( "MetadataService@databoss" ).getDictionary()#">
	</cfif>

	<!---Event --->
	#announceInterception( "db_beforeBodyEnd" )#

<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
<!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
<![endif]-->
</body>
</cfoutput>
</html>