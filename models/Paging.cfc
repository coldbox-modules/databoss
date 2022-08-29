<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2012 Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano
License		: 	Apache 2 License
Description :
	A paging plugin.

To use this plugin you need to create some settings in your coldbox.xml and some
css entries.

DATABOSS SETTINGS
- PagingMaxRows : The maximum number of rows per page.
- PagingBandGap : The maximum number of pages in the page carrousel

----------------------------------------------------------------------->
<cfcomponent hint="A DataBoss paging model"	 output="false" singleton>

	<!--- DI --->
	<cfproperty name="moduleSettings" 	inject="coldbox:moduleSettings:databoss">
	<cfproperty name="requestService" 	inject="coldbox:requestService">
	<cfproperty name="resourceService" 	inject="resourceService@cbi18n">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

    <cffunction name="init" access="public" returntype="Paging" output="false">
		<cfscript>
  		//Return instance
  		return this;
		</cfscript>
	</cffunction>

	<cffunction name="onDIComplete">
		<cfscript>
			// Paging properties
	  		setPagingMaxRows( moduleSettings.PagingMaxRows );
	  		setPagingBandGap( moduleSettings.PagingBandGap );
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get/Set paging max rows --->
	<cffunction name="getPagingMaxRows" access="public" returntype="numeric" hint="Get the paging max rows setting" output="false">
		<cfreturn instance.pagingMaxRows>
	</cffunction>
	<cffunction name="setPagingMaxRows" access="public" returntype="void" hint="Set the paging max rows setting" output="false">
		<cfargument name="pagingMaxRows" required="true" type="numeric">
		<cfset instance.pagingMaxRows = arguments.pagingMaxRows>
	</cffunction>

	<!--- Get/Set paging band gap --->
	<cffunction name="getPagingBandGap" access="public" returntype="numeric" hint="Get the paging carrousel band gap" output="false">
		<cfreturn instance.PagingBandGap>
	</cffunction>
	<cffunction name="setPagingBandGap" access="public" returntype="void" hint="Set the paging band gap" output="false">
		<cfargument name="PagingBandGap" required="true" type="numeric">
		<cfset instance.PagingBandGap = arguments.PagingBandGap>
	</cffunction>

	<!--- Get boundaries --->
	<cffunction name="getboundaries" access="public" returntype="struct" hint="Calculate the startrow and maxrow" output="false" >
		<cfargument name="PagingMaxRows" required="false" type="numeric" hint="You can override the paging max rows here.">
		<cfscript>
			var boundaries = structnew();
			var event = requestService.getContext();
			var maxRows = getPagingMaxRows();

			/* Check for Override */
			if( structKeyExists(arguments,"PagingMaxRows") ){
				maxRows = arguments.pagingMaxRows;
			}

			boundaries.startrow = (event.getValue("page",1) * maxrows - maxRows);
			boundaries.maxrow   = boundaries.startrow + maxRows;

			return boundaries;
		</cfscript>
	</cffunction>

	<!--- render paging --->
	<cffunction name="renderit" access="public" returntype="any" hint="render plugin tabs" output="false" >
		<!--- ***************************************************************** --->
		<cfargument name="FoundRows"    required="true"  type="numeric" hint="The found rows to page">
		<cfargument name="link"   		required="true"  type="string"  hint="The link to use, you must place the @page@ place holder so the link ca be created correctly">
		<cfargument name="PagingMaxRows" required="false" type="numeric" hint="You can override the paging max rows here.">
		<!--- ***************************************************************** --->
		<cfset var event = requestService.getContext()>
		<cfset var pagingTabs = "">
		<cfset var maxRows = getPagingMaxRows()>
		<cfset var bandGap = getPagingBandGap()>
		<cfset var totalPages = 0>
		<cfset var theLink = arguments.link>
		<!--- Paging vars --->
		<cfset var currentPage = event.getValue("page",1)>
		<cfset var pageFrom = 0>
		<cfset var pageTo = 0>
		<cfset var pageIndex = 0>

		<!--- Override --->
		<cfif structKeyExists(arguments, "pagingMaxRows")>
			<cfset maxRows = arguments.pagingMaxRows>
		</cfif>

		<!--- Only page if records found --->
		<cfif arguments.FoundRows neq 0>
			<!--- Calculate Total Pages --->
			<cfset totalPages = Ceiling( arguments.FoundRows / maxRows )>

			<!--- ***************************************************************** --->
			<!--- Paging Tabs 														--->
			<!--- ***************************************************************** --->
			<cfsavecontent variable="pagingtabs">
			<cfoutput>
			<div>

				<div class="pagingTabsTotals">
					<span class="label label-info">#resourceService.getResource( resource='db_paging_total_records', bundle="db" )#: #arguments.FoundRows# </span> &nbsp;
					<span class="label label-info">#resourceService.getResource( resource='db_paging_total_pages', bundle="db" )#: #totalPages# </span>
				</div>

				<cfif totalPages gt 1>
					<div class="pagingCarrousel">
						<ul class="pagination">
						<!--- PREVIOUS PAGE --->
						<cfif currentPage-1 gt 0>
							<li>
								<a href="#replace(theLink,"@page@",currentPage-1)#">&lt;&lt;</a>
							</li>
						</cfif>

						<!--- Calcualte PageFrom Carrousel --->
						<cfset pageFrom=1>
						<cfif (currentPage-bandGap) gt 1>
							<cfset pageFrom=currentPage-bandgap>
							<li><a href="#replace(theLink,"@page@",1)#">1</a></li>
							<li class="disabled">
								<a href="javascript:null">...</a>
							</li>
						</cfif>

						<!--- Page TO of Carrousel --->
						<cfset pageTo=currentPage+bandgap>
						<cfif (currentPage+bandgap) gt totalPages>
							<cfset pageTo=totalPages>
						</cfif>
						<cfloop index="pageIndex" from="#pageFrom#" to="#pageTo#">
							<li>
								<a href="#replace(theLink,"@page@",pageIndex)#"
							   <cfif currentPage eq pageIndex>class="selected"</cfif>>#pageIndex#</a>
							</li>
						</cfloop>

						<!--- End Token --->
						<cfif (currentPage+bandgap) lt totalPages>
							<li class="disabled"><a href="javascript:null">...</a></li>
							<li><a href="#replace(theLink,"@page@",totalPages)#">#totalPages#</a></li>
						</cfif>

						<!--- NEXT PAGE --->
						<cfif (currentPage+bandgap) lt totalPages >
							<li>
								<a href="#replace(theLink,"@page@",currentPage+1)#">&gt;&gt;</a>
							</li>
						</cfif>
						</ul>
					</div>
				</cfif>

			</div>
			</cfoutput>
			</cfsavecontent>
		</cfif>

		<cfreturn pagingTabs>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>