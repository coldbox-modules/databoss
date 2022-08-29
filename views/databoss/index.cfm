<!---
********************************************************************************
Copyright 2012 Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
--->
<cfoutput>
<!--- NavBar --->
<cfif !prc.export>
	#renderView( view="_global/_navbar", module="databoss" )#
</cfif>

<cfif arraylen( prc.systemEntities )>
<!---Listing Header --->
<div>
	<!--- Entity Actions --->
	<cfif !prc.export>
	<div class="btn-group pull-right">
		<!---Add Record --->
		<a class="btn btn-info btn-sm" href="#event.buildLink('databoss.entity.#rc.safeEntity#.create')#">
			<i class="glyphicon glyphicon-plus icon-white"></i> <span class="hidden-sm hidden-xs inline">#getResource('db_record_add@db')#</span>
		</a>
		<!---Delete Record --->
		<a class="btn btn-danger btn-sm" href="javascript:confirmDelete()">
			<i class="glyphicon glyphicon-remove icon-white"></i> <span class="hidden-sm hidden-xs inline">#getResource('db_record_delete@db')#</span>
		</a>
	</div>
	</cfif>
	<h1>#prc.mdDictionary.displayName# <span class="label label-info">#prc.listingCount#</span></h1>
	<br>
</div>

<!---MessageBox --->
<cfif flash.exists( "notice" )>
	<div class="alert alert-dismissable alert-#flash.get( "notice" ).type#">
		 <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
		 #flash.get( "notice" ).message#
	</div>
</cfif>

<cfif prc.listingCount>
	<cfif !prc.export>
	<!--- Table Filter --->
	<form class="well well-sm form-inline" role="form">
		<div class="row">

			<!--- Exports --->
			<div class="pull-right" style="margin-right:10px">
				<!---Loader --->
				<div id="loaderBar" class="pull-right hidden">
					<img src="#prc.modRoot#includes/images/ajax-loader-horizontal.gif" alt="loader" />
					<img src="#prc.modRoot#includes/images/ajax-loader-horizontal.gif" alt="loader" />
				</div>
				<!--- Show All --->
				<a href="#event.buildLink( 'databoss.entity.' & rc.safeEntity & '.showAll' )#" class="btn btn-default btn-sm">
					<i class="glyphicon glyphicon-list"></i> <span class="hidden-sm hidden-xs inline">#getResource("db_general_showall@db")#</a>
				</a>
				<!---Exports --->
				<div class="btn-group">
			    	<button type="button" class="btn btn-sm btn-default dropdown-toggle" data-toggle="dropdown">
						<i class="glyphicon glyphicon-download-alt"></i>  <span class="hidden-sm hidden-xs inline">#getResource("db_export@db")#</span>
						<span class="caret"></span>
					</button>
			    	<ul class="dropdown-menu" role="menu">
			    		<li><a href="#event.buildLink( 'databoss.entity.' & rc.safeEntity & '.export.json' )#" 	target="_blank">JSON</a></li>
						<li><a href="#event.buildLink( 'databoss.entity.' & rc.safeEntity & '.export.jsonp' )#" target="_blank">JSONP</a></li>
						<li><a href="#event.buildLink( 'databoss.entity.' & rc.safeEntity & '.export.xml' )#" 	target="_blank">XML</a></li>
						<li><a href="#event.buildLink( 'databoss.entity.' & rc.safeEntity & '.export.wddx' )#" 	target="_blank">WDDX</a></li>
						<li><a href="#event.buildLink( 'databoss.entity.' & rc.safeEntity & '.export.pdf' )#" 	target="_blank">PDF</a></li>
			    	</ul>
			    </div>
			</div>

			<div class="col-xs-5">
				<!---Filter --->
				<input type="search" id="entityFilter" class="form-control" placeholder="#getResource("db_data_filter@db")#">
			</div>
		</div>
	</form>
	</cfif>
<cfelse>
	<p class="text-muted alert alert-danger">
		<i class="glyphicon glyphicon-exclamation-sign icon-2x"></i>
		#getResource('db_record_none_found@db')#
		<a href="#event.buildLink('databoss.entity.#rc.safeEntity#.create')#">#getResource('db_record_none_found_link@db')#</a>.
	</p>
</cfif>

<!--- Listing Form --->
#html.startForm( name="entityForm", action=prc.xehEntityDelete, method="post", ssl=event.isSSL() )#
	<!--- The lookup class selected for deletion purposes --->
	#html.hiddenField(name="entity", value="#rc.entity#")#

	<!--- Render Results --->
	<cfif prc.listingCount>
	<table class="table table-striped table-hover" width="100%" id="entityTable" cellspacing="1" cellpadding="0" border="0">
		<thead>
		<!--- Display Fields Found in Query --->
		<tr>
			<!---CB Holder --->
			<cfif !prc.export>
				<th id="checkboxHolder" class="{sorter: false}" width="15">
				<input type="checkbox" name="checkAllAuto" id="checkAllAuto" />
			</th>
			</cfif>

			<!--- All Other Fields --->
			<cfloop array="#prc.mdDictionary.properties#" index="thisProp">
				<cfif thisProp.display>
					<th class="{sorter: 'text'}">#thisProp.labelText#</th>
				</cfif>
			</cfloop>

			<!--- Singular Relationships --->
			<cfloop array="#prc.mdDictionary.singularRelations#" index="thisRel">
				<cfif thisRel.display>
					<th class="{sorter: 'text'}">#thisRel.labelText#</th>
				</cfif>
			</cfloop>

			<!--- Actions --->
			<cfif !prc.export>
			<th id="actions" class="{sorter: false} centered" width="100">#getResource( "db_general_actions@db" )#</th>
			</cfif>
		</tr>
		</thead>

		<!--- Loop Through Query Results --->
		<tbody>
		<cfloop array="#prc.aListing#" index="thisRow">
		<cfset thisRowID = invoke( thisRow, "get#prc.mdDictionary.pk.name#" )>
		<tr>
			<!--- Delete Checkbox with PK--->
			<cfif !prc.export>
			<td>
				<input type="checkbox" name="entityID" id="entityID_#thisRowID#" value="#thisRowID#" class="checkbox"/>
			</td>
			</cfif>
			<!--- Loop Through Columns and their values --->
			<cfloop from="1" to="#arrayLen( prc.mdDictionary.properties )#" index="i">
				<!---Get value and nullify checks --->
				<cfset thisValue = invoke( thisRow, "get#prc.mdDictionary.properties[ i ].name#" )>
				<cfif isNull( thisValue )><cfset thisValue = '<null>'></cfif>
				<!---Don't show display eq false --->
				<cfif prc.mdDictionary.properties[ i ].display>
				<td>
					<!--- Boolean Format --->
					<cfif prc.mdDictionary.properties[ i ].datatype eq "boolean" and isBoolean( thisValue )>
						#yesnoFormat( thisValue )#
					<!--- Dates --->
					<cfelseif prc.mdDictionary.properties[ i ].datatype eq "date" and isDate( thisValue )>

						<!--- List Dates? --->
						<cfif prc.mdDictionary.properties[ i ].showDate>
							<!--- date format --->
							<cfif len( prc.mdDictionary.properties[ i ].dateformat )>
								#dateFormat( thisValue, prc.mdDictionary.properties[ i ].dateformat )#
							<cfelse>
								#dateFormat( thisValue )#
							</cfif>
						</cfif>

						<!--- List Dates? --->
						<cfif prc.mdDictionary.properties[ i ].showTime>
							<!--- time format --->
							<cfif len( prc.mdDictionary.properties[ i ].timeformat )>
								#timeFormat( thisValue, prc.mdDictionary.properties[ i ].timeFormat )#
							<cfelse>
								#timeFormat( thisValue )#
							</cfif>
						</cfif>
					<!--- Everything Else --->
					<cfelse>
						<!--- Null First --->
						<cfif thisValue eq "<null>">
							<span class="label label-warning"><em>null</em></span>
						<!--- Max Len --->
						<cfelseif len( thisValue ) gt getModuleSettings( "databoss" ).listingMaxChars>
							<div id="cell_#prc.mdDictionary.properties[ i ].name#_#thisRowID#">
								#left( htmlEditFormat( thisValue ), getModuleSettings( "databoss" ).listingMaxChars )#
								<a href="javascript:showFullCellContent( '#prc.mdDictionary.properties[ i ].name#_#thisRowID#' )"
								   rel="tooltip"
								   class="btn btn-default btn-xs"
								   title="Content truncated click to expand">
								   	<i class="glyphicon glyphicon-plus"></i>
								</a>
							</div>
							<div id="cellfull_#prc.mdDictionary.properties[ i ].name#_#thisRowID#" style="display:none">
								#htmlEditFormat( thisValue )#
								<a href="javascript:hideFullCellContent( '#prc.mdDictionary.properties[ i ].name#_#thisRowID#' )"
								   rel="tooltip"
								   class="btn btn-default btn-xs"
								   title="Contract Content">
								   	<i class="glyphicon glyphicon-minus"></i>
								</a>
							</div>
						<!--- Default --->
						<cfelse>
							#htmlEditFormat( thisValue )#
						</cfif>
					</cfif>
				</td>
				</cfif>
			</cfloop>
			<!--- Loop Singluar Relationship Data --->
			<cfloop array="#prc.mdDictionary.singularRelations#" index="thisRel">
				<cfif thisRel.display>
					<!--- Built out the display column values --->
					<cfset thisValue = prc.entityDisplayHelper.buildDisplayColumns( thisRow, thisRel )>

					<!--- Display TD --->
					<td>
						<!--- Null First --->
						<cfif thisValue eq "<null>">
							<span class="label label-warning"><em>null</em></span>
						<!--- Default --->
						<cfelse>
							#htmlEditFormat( thisValue )#
						</cfif>
					</td>
				</cfif>
			</cfloop>

			<cfif !prc.export>
			<!--- Display Commands --->
			<td class="centered">
				<div class="btn-group">
				<!---Edit --->
				<a class="btn btn-sm btn-info"
					rel="tooltip"
					title="#getResource( 'db_record_edit@db' )#"
					href="#event.buildLink( prc.xehEntityList )#/#rc.safeEntity#/id/#thisRowID#">
					<i class="glyphicon glyphicon-edit icon-white"></i>
				</a>
				<!---Delete --->
				<a class="btn btn-sm btn-danger"
					rel="tooltip"
					title="#getResource( 'db_record_remove@db' )#"
					href="javascript:confirmDelete( '#thisRowID#' )">
					<i class="glyphicon glyphicon-remove icon-white"></i>
				</a>
				</div>
			</td>
			</cfif>
		</tr>
		</cfloop>
		</tbody>
	</table>
	</cfif>

	<hr/>

	<!--- Paging --->
	<cfif prc.listingCount>
		<div>
			#prc.oPaging.renderit(foundRows=prc.listingCount, link=prc.pagingLink)#
		</div>
	</cfif>

	<div id="formFinalizer"></div>
</form>
<cfelse>
	<div class="alert alert-danger">
		<strong>#getResource('db_general_oops@db')#</strong>
		<p>#getResource('db_entity_none@db')#</p>
	</div>
</cfif>
</cfoutput>