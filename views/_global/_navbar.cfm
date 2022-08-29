<cfoutput>
<nav class="navbar navbar-default" role="navigation" id="main-navbar">

	<!---Navbar header --->
	<div class="navbar-header">
		<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="##main-navbar-collapse">
			<span class="sr-only">Toggle navigation</span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
		</button>
		<div>
			<!--- DO NOT REMOVE WHITESPACE AS IT IS USED IN BUILD PROCESS --->
			<!---Branding Logo --->
			<cfif getModuleSettings( "databoss" ).showLogo>
			<a href="#event.buildLink( prc.xehDataboss )#" class="navbar-brand"><img src="#prc.modRoot#includes/images/databoss-top-header.png" alt="logo" style="margin:5px"/></a>
			</cfif>
			<!---Event --->
			#announceInterception( "db_header_logo" )#
		</div>
	</div>

	<!--- Responsive Menu --->
	<div class="collapse navbar-collapse" id="main-navbar-collapse">
		<!---Event --->
		#announceInterception( "db_leftnavbar_start" )#

		<ul class="nav navbar-nav">

			<li>
				<a href="#event.buildLink( prc.xehDataboss )#">
					<i class="fa fa-database"></i> #$r( 'db_manage_entity@db' )#
			   </a>
		   </li>

			<cfif getModuleSettings( "databoss" ).showGlobalActions>
			<!---Global Actions --->
			<li class="dropdown">
				<a href="##" class="dropdown-toggle" data-toggle="dropdown">
					<i class="glyphicon glyphicon-wrench"></i> #$r( 'db_global_actions@db' )# <b class="caret"></b>
				</a>
				<ul id="actions-submenu" class="dropdown-menu">
					 <li>
					 	<a href="#event.buildLink( prc.xehDictionaryClean & '?returnURL=' & event.getCurrentRoutedURL() )#">
							<i class="glyphicon glyphicon-book"></i> #$r( 'db_reload_metadata@db' )#
						</a>
					</li>
					<li>
					 	<a href="#event.buildLink( prc.xehReloadORM & '?returnURL=' & event.getCurrentRoutedURL() )#">
					 		<i class="glyphicon glyphicon-refresh"></i> #$r( 'db_reload_orm@db' )#
						</a>
					</li>
					<li>
					 	<a href="#event.buildLink( prc.xehReloadApp & '?returnURL=' & event.getCurrentRoutedURL() )#">
					 		<i class="glyphicon glyphicon-off"></i> #$r( 'db_reload_application@db' )#
						</a>
					</li>
				</ul>
			</li>
			</cfif>

		</ul>

		<!--- Language Options --->
		<cfif getModuleSettings( "databoss" ).showLanguageOptions>
		<ul class="nav navbar-nav">
			<li class="dropdown">
				<a href="##" class="dropdown-toggle" data-toggle="dropdown">
					<i class="glyphicon glyphicon-globe"></i>
					#$r( 'db_language_' & getfwLocale() & '@db' )#
					<b class="caret"></b>
				</a>
				<ul id="language-submenu" class="dropdown-menu">
					<li class="dropdown-header">#$r( 'db_languages@db' )#</li>
					<cfloop array="#getModuleSettings( "databoss" ).supportedLanguages#" index="language">
						<cfif prc.userLocale neq language>
							<li>
								<!--- TODO : figure out the best way to create this link
								<a href="#event.buildLink(linkto='databoss', queryString='?locale=' & language)#">#$r( 'db_language_' & language)#</a>
								 --->
								<a href="#event.buildLink(linkto='databoss/?locale=' & language)#">#$r( 'db_language_' & language & '@db' )#</a>
							</li>
						</cfif>
					</cfloop>
				</ul>
			</li>
		</ul>
		</cfif>

		<!---Event --->
		#announceInterception( "db_leftnavbar_end" )#

		#announceInterception( "db_rightnavbar_end" )#

		<!--- DO NOT REMOVE WHITESPACE AS IT IS USED IN BUILD PROCESS --->
		<!---About --->
		<cfif getModuleSettings( "databoss" ).showAbout>
		<ul class="nav navbar-nav navbar-right">
			<li class="dropdown">
				<a href="##" class="dropdown-toggle" data-toggle="dropdown">
					<i class="glyphicon glyphicon-info-sign"></i> #$r( 'db_site_about@db' )# <b class="caret"></b>
				</a>
				<ul id="about-submenu" class="dropdown-menu">
					 <li class="dropdown-header">#getModuleConfig("databoss").title# v#getModuleConfig( "databoss" ).version#</li>
					 <li><a href="https://groups.google.com/a/ortussolutions.com/forum/##!forum/databoss" target="_blank"><i class="glyphicon glyphicon-fire"></i> #$r( 'db_site_report_bug@db' )#</a></li>
					 <li><a href="mailto:help@ortussolutions.com?subject=DataBoss-Feedback"><i class="glyphicon glyphicon-bullhorn"></i> #$r( 'db_site_send_feedback@db' )#</a></li>
					 <li><a href="http://www.ortussolutions.com"><i class="glyphicon glyphicon-home"></i> Ortus Solutions #$r( 'db_site_support@db' )#</a></li>
					 <li class="text-center">
					 	<img src="#prc.modRoot#includes/images/ortus_logo.png" alt="logo"/>
					 </li>
				</ul>
			</li>
		</ul>
		</cfif>
		#announceInterception( "db_rightnavbar_start" )#

	</div> <!--- end responsive container --->
</nav> <!---end navbar --->
</cfoutput>