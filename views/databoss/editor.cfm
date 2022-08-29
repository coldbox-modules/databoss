<!---
********************************************************************************
Copyright 2012 Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
--->
<cfoutput>
<!--- NavBar --->
<cfif !prc.export>
#renderView(view="_global/_navbar", module="databoss")#
</cfif>

<!--- Header --->
<div class="page-header">
	<cfif !prc.export>
	<!--- Entity Actions --->
	<div class="btn-group pull-right">
		<!---Add Record --->
		<a class="btn btn-primary btn-sm" href="#event.buildLink('#prc.xehEntityList#.#rc.safeEntity#')#"><i class="glyphicon glyphicon-arrow-left icon-white"></i> #getResource('db_back_listings@db')#</a>
	</div>
	</cfif>
	<h1>#prc.mdDictionary.displayName# <cfif !prc.export><span class="label label-info">#getResource('db_record_edit@db')#</span></cfif></h1>
</div>

<!--- Exports --->
<cfif !prc.export>
<div class="pull-right">
	<div class="btn-group">
    	<a class="btn btn-default dropdown-toggle btn-sm" data-toggle="dropdown" href="##">
			<i class="glyphicon glyphicon-download-alt"></i> #getResource("db_export@db")# <span class="caret"></span>
		</a>
    	<ul class="dropdown-menu">
    		<li><a href="#event.buildLink( 'databoss.entity.' & rc.safeEntity & '.id.' & prc.pkValue & '.format.json' )#" 	target="_blank">JSON</a></li>
			<li><a href="#event.buildLink( 'databoss.entity.' & rc.safeEntity & '.id.' & prc.pkValue & '.format.jsonp' )#" 	target="_blank">JSONP</a></li>
			<li><a href="#event.buildLink( 'databoss.entity.' & rc.safeEntity & '.id.' & prc.pkValue & '.format.xml' )#" 	target="_blank">XML</a></li>
			<li><a href="#event.buildLink( 'databoss.entity.' & rc.safeEntity & '.id.' & prc.pkValue & '.format.wddx' )#" 	target="_blank">WDDX</a></li>
			<li><a href="#event.buildLink( 'databoss.entity.' & rc.safeEntity & '.id.' & prc.pkValue & '.format.pdf' )#" 	target="_blank">PDF</a></li>
    	</ul>
    </div>
</div>
</cfif>

<cfif !prc.export>
<!---Tab Navigation --->
<ul class="nav nav-tabs" id="contentTabs">
  <li class="active">
    <a href="##editorTab" data-toggle="tab"><i class="glyphicon glyphicon-edit"></i> #getResource('db_record_entity_editor@db')#</a>
  </li>
  <li><a href="##collectionsTab" data-toggle="tab"><i class="glyphicon glyphicon-th"></i> #getResource('db_relationship_collection_manager@db')#</a></li>
</ul>
</cfif>
<!---Tab Content --->
<div class="tab-content">
	<!---Entity Editor --->
    <div class="tab-pane active" id="editorTab">
    	#renderView(view="databoss/editor_manager")#
    </div>
	<!---Collection Managers --->
    <div class="tab-pane" id="collectionsTab">
    	#renderView(view="databoss/editor_collections")#
    </div>
	</div>
</cfoutput>