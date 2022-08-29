<!---
********************************************************************************
Copyright 2012 Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
--->
<cfoutput>
<!--- NavBar --->
#renderView( view="_global/_navbar", module="databoss" )#

<!--- Only show if managing entities --->
<cfif arraylen( prc.systemEntities )>
	<!--- Title --->
	<h2><i class="fa fa-database"></i> #$r( "db_manage_entity@db" )# <span class="label label-info">#prc.systemEntities.len()#</span></h2>

	<!---MessageBox --->
	<cfif flash.exists( "notice" )>
		<div class="alert alert-dismissable alert-#flash.get( "notice" ).type#">
			<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
			#flash.get( "notice" ).message#
		</div>
	</cfif>

	<!--- Table Filter --->
	<form class="well well-sm" role="form">

			<!--- Exports --->
			<div class="pull-right" style="margin-right:10px">

				<!---Loader --->
				<div id="loaderBar" class="pull-right hidden">
					<img src="#prc.modRoot#includes/images/ajax-loader-horizontal.gif" alt="loader" />
					<img src="#prc.modRoot#includes/images/ajax-loader-horizontal.gif" alt="loader" />
				</div>

			</div>

			<!---Filter --->
			<input type="search" id="entityFilter" class="form-control" placeholder="#$r( "db_general_filter@db" )#">
	</form>

	<!--- Render Entity Management List --->
	<table class="table table-striped table-hover" width="100%" id="entityTable" cellspacing="1" cellpadding="0" border="0">
		<thead>
			<!--- Display Fields Found in Query --->
			<tr>
				<th>
					#$r( "db_general_entity@db" )#
				</th>

				<!--- Actions --->
				<th id="actions" class="{sorter: false} centered" width="100">#$r( "db_general_actions@db" )#</th>
			</tr>
		</thead>

		<tbody>
			<cfloop array="#prc.systemEntities#" index="thisEntity">
				<tr>
					<td>
						<a href="#event.buildLink( prc.xehEntityList & "/" & urlEncodedFormat( thisEntity ) )#/">#prc.systemDictionary[ thisEntity ].displayName#</a>
						<cfif prc.systemDictionary[ thisEntity ].readOnly>
							<br><span class="label label-warning">Read Only</span>
						</cfif>
					</td>

					<td class="centered">
						<div class="btn-group">
						<!--- Manage --->
						<a class="btn btn-sm btn-info"
							rel="tooltip"
							title="#$r( 'db_general_manage@db' )#"
							href="#event.buildLink( prc.xehEntityList & "/" & urlEncodedFormat( thisEntity ) )#">
							<i class="fa fa-table"></i>
						</a>
						</div>
					</td>
				</tr>
			</cfloop>
		</tbody>
	</table>

<cfelse>
	<div class="alert alert-danger">
		<strong>#$r('db_general_oops@db')#</strong>
		<p>#$r('db_entity_none@db')#</p>
	</div>
</cfif>
</cfoutput>