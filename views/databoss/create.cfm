<!---
********************************************************************************
Copyright 2012 Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
--->
<cfoutput>
<!--- NavBar --->
#renderView(view="_global/_navbar", module="databoss")#

<!--- Header --->
<div class="page-header">
	<!--- Entity Actions --->
	<div class="btn-group pull-right">
		<!---Add Record --->
		<a class="btn btn-primary btn-sm" href="#event.buildLink('#prc.xehEntityList#.#rc.safeEntity#')#"><i class="glyphicon glyphicon-arrow-left icon-white"></i> #getResource('db_back_listings@db')#</a>
	</div>
	<h1>#prc.mdDictionary.displayName# <span class="label label-info">#getResource('db_record_add@db')#</span></h1>
</div>

<!---MessageBox --->
<cfif flash.exists( "notice" )>
	<div class="alert alert-dismissable alert-#flash.get( "notice" ).type#">
		 <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
		 #flash.get( "notice" ).message#
	</div>
</cfif>

<!--- Add Form --->
#html.startForm( name="entityForm", action="#prc.xehEntityList#/#rc.entity#/doCreate", role="form", class="form-horizontal", ssl=event.isSSL())#
	<!--- hidden entity --->
	#html.hiddenField( name="entity", value="#rc.entity#" )#
	<!--- Return URL Value --->
	#html.hiddenField( name="rURL", value=HTMLEditFormat( rc.rURL ) )#

	<div id="lookupFields">
	<fieldset>

		<!---=========================== SINGULAR RELATIONS ============================== --->
		<!--- Loop Through Singular Relations, to create Drop Downs, except oneToOne relations --->
		<cfloop from="1" to="#arrayLen(prc.mdDictionary.singularRelations)#" index="i">
		<cfset currentRelationship = prc.mdDictionary.singularRelations[i] />
		<cfif NOT currentRelationship.isOneToOne>
			<cfset Listing = prc["#currentRelationship.alias#"]>
			<div class="form-group">
				<!--- Singular Relation Label --->
				<label class="col-sm-2 control-label" for="fk_#currentRelationship.alias#">#currentRelationship.labelText#: </label>

				<cfif arrayLen( Listing ) >
					<div class="col-sm-10">
					<!--- Singular Relation Data --->
					<select name="fk_#currentRelationship.alias#"
							id="fk_#currentRelationship.alias#"
							class="form-control"
							<cfif currentRelationship.notNull>required="true"</cfif>>
						<option></option>
						<cfloop array="#Listing#" index="thisItem">
							<cfset thisItemPK = invoke( thisItem, "get#prc.mdDictionary.singularRelations[i].PK.name#" )>
							<option value="#thisItemPK#"
									<cfif structKeyExists(rc, currentRelationship.sourceEntity) and
										  rc[ currentRelationship.sourceEntity ] eq thisItemPK>selected</cfif>>
								#prc.entityDisplayHelper.buildDisplayColumns( prc.oEntity, prc.mdDictionary.singularRelations[i], thisItem )#
							</option>
						</cfloop>
					</select>
					</div>
				<cfelse>
					<div class="alert alert-danger">
						#replace(getResource('db_record_none@db'), '{1}', currentRelationship.alias)#
						<a href="#event.buildLink('databoss.entity.#currentRelationship.sourceEntity#.create')#">#getResource('db_record_create@db')#</a>
						#getResource('db_record_create_now@db')#
					</div>
				</cfif>
			</div>
		</cfif>
		</cfloop>
		<!---=========================== END SINGULAR RELATIONS ============================== --->

		<!--- Loop through Normal Properties --->
		<cfloop from="1" to="#ArrayLen(prc.mdDictionary.properties)#" index="i">
			<cfset currentProperty = prc.mdDictionary.properties[i] />
			<!--- Get Default value --->
			<cfset thisDefaultValue = invoke( prc.oEntity, "get#currentProperty.name#" )>
			<cfif isNull( thisDefaultValue )><cfset thisDefaultValue = ""></cfif>

			<!--- Help Text --->
			<cfset helpTextHTML = "">
			<cfif len( currentProperty.helpText )>
				<cfset helpTextHTML = '<p class="help-block">#currentProperty.helpText#</p>'>
			</cfif>

			<!--- Do not show the ignore Inserts and no displayCreate--->
			<cfif currentProperty.insert and currentProperty.displayCreate>
			<div class="form-group">

				<!--- PROPERTY LABEL --->
				<label class="control-label col-sm-2" for="#currentProperty.name#">
					<cfif currentProperty.notNull><strong>*</strong> </cfif>#currentProperty.labelText#:
				</label>

				<!--- BOOLEAN TYPES --->
				<cfif currentProperty.datatype eq "boolean">
					<div class="col-sm-10">
						<cfif currentProperty.html eq "radio">
							<label class="radio">#getResource('db_general_yes@db')#
								<input type="radio"
									name="#currentProperty.name#"
									id="#currentProperty.name#"
									value="1"
									<cfif isBoolean( thisDefaultValue ) and thisDefaultValue>checked="checked"<cfelse>checked="checked"</cfif>
								/>
							</label>

							<label class="radio">#getResource('db_general_no@db')#
								<input type="radio"
								   name="#currentProperty.name#"
								   id="#currentProperty.name#"
								   value="0"
								   <cfif isBoolean( thisDefaultValue )>checked="checked"</cfif>/>
							</label>
						<cfelseif currentProperty.html eq "select">
							<select name="#currentProperty.name#"
									id="#currentProperty.name#"
									class="form-control">
								<option value="1" <cfif isBoolean( thisDefaultValue ) and thisDefaultValue>selected="selected"</cfif> >#getResource('db_general_true@db')#</option>
								<option value="0" <cfif isBoolean( thisDefaultValue ) and !thisDefaultValue>selected="selected"</cfif>>#getResource('db_general_false@db')#</option>
							</select>
						<cfelse>
						    <div class="btn-group" data-toggle="buttons">
								<label class="btn btn-default<cfif isBoolean( thisDefaultValue ) and thisDefaultValue> active</cfif>">
								    <input
								    	type="radio"
								    	name="#currentProperty.name#"
								    	id="option1"
								    	value="1"
								    	<cfif isBoolean( thisDefaultValue ) and thisDefaultValue>checked="checked"</cfif>> #getResource('db_general_yes@db')#
								</label>
								<label class="btn btn-default<cfif isBoolean( thisDefaultValue ) and !thisDefaultValue> active</cfif>">
								    <input
								    	type="radio"
								    	name="#currentProperty.name#"
								    	id="option2"
								    	value="0"
								    	<cfif isBoolean( thisDefaultValue ) and !thisDefaultValue>checked="checked"</cfif>> #getResource('db_general_no@db')#
								</label>
						    </div>
						</cfif>
						<!--- help text HTML --->
						#helpTextHTML#
					</div>
				<!--- DATE TYPE --->
				<cfelseif currentProperty.datatype eq "date">

					<!---HTML Types --->
					<cfswitch expression="#currentProperty.html#" >

						<cfcase value="time">
							<div class="col-sm-3">
								<div class="input-group">
									<input id="#currentProperty.name#"
										name="#currentProperty.name#"
										class="clockpicker form-control"
										data-show-seconds="#currentProperty.timeSeconds#"
										data-show-meridian="#currentProperty.timeMeridian#"
										<cfif len( thisDefaultValue )>value="#thisDefaultValue#"<cfelse>value=""</cfif>
										<cfif len( currentProperty.placeholder )>placeholder="#currentProperty.placeholder#"</cfif>
										<cfif len( currentProperty.helpText )>title="#currentProperty.helpText#"</cfif>
										<cfif currentProperty.notNull>required="true"</cfif>
										<cfif len(currentProperty.validate)>pattern="#currentProperty.validate#"</cfif>
										type="text"/>
									<span class="input-group-addon"><i class="glyphicon glyphicon-time"></i></span>
								</div>
								<!--- help text HTML --->
								#helpTextHTML#
							</div>
						</cfcase>

						<cfcase value="datetime">
							<div class="col-sm-3">
								<!--- hidden value --->
								<input type="hidden" name="#currentProperty.name#" id="#currentProperty.name#" value="" >

								<div class="input-group">
									<input type="text"
										size="20"
										name="#currentProperty.name#-dField"
										id="#currentProperty.name#-dField"
										<cfif len( thisDefaultValue )>value="#thisDefaultValue#"<cfelse>value=""</cfif>
										<cfif len( currentProperty.dateFormat )>data-date-format="#currentProperty.dateFormat#"</cfif>
										<cfif len( currentProperty.helpText)>title="#currentProperty.helpText#"</cfif>
										<cfif currentProperty.notNull>required="true"</cfif>
										class="datepicker form-control"
										onchange="updateDTField( '#currentProperty.name#' )"/>
									<span class="input-group-addon"><i class="glyphicon glyphicon-calendar"></i></span>
								</div>

								&nbsp;

								<div class="input-group">
									<input id="#currentProperty.name#-tField"
										name="#currentProperty.name#-tField"
										class="clockpicker form-control"
										data-show-seconds="#currentProperty.timeSeconds#"
										data-show-meridian="#currentProperty.timeMeridian#"
										<cfif len( thisDefaultValue )>value="#thisDefaultValue#"<cfelse>value=""</cfif>
										<cfif len( currentProperty.placeholder )>placeholder="#currentProperty.placeholder#"</cfif>
										<cfif len( currentProperty.helpText )>title="#currentProperty.helpText#"</cfif>
										<cfif currentProperty.notNull>required="true"</cfif>
										<cfif len(currentProperty.validate)>pattern="#currentProperty.validate#"</cfif>
										type="text"
										onchange="updateDTField( '#currentProperty.name#' )"/>
									<span class="input-group-addon"><i class="glyphicon glyphicon-time"></i></span>
								</div>

								<!--- help text HTML --->
								#helpTextHTML#
							</div>
						</cfcase>

						<cfdefaultcase>
							<div class="col-sm-3">
								<div class="input-group">
									<input type="text"
										size="20"
										name="#currentProperty.name#"
										id="#currentProperty.name#"
										<cfif len( thisDefaultValue )>value="#thisDefaultValue#"<cfelse>value=""</cfif>
										<cfif len( currentProperty.dateFormat )>data-date-format="#currentProperty.dateFormat#"</cfif>
										<cfif len( currentProperty.helpText)>title="#currentProperty.helpText#"</cfif>
										<cfif currentProperty.notNull>required="true"</cfif>
										class="datepicker form-control" />
									<span class="input-group-addon"><i class="glyphicon glyphicon-calendar"></i></span>
								</div>
								<!--- help text HTML --->
								#helpTextHTML#
							</div>
						</cfdefaultcase>

					</cfswitch>

				<!--- Time picker --->
				<cfelseif currentProperty.html eq "time">

					<div class="bootstrap-clockpicker col-sm-3">
						<div class="input-group">
							<input id="#currentProperty.name#"
								name="#currentProperty.name#"
								class="clockpicker form-control"
								data-show-seconds="#currentProperty.timeSeconds#"
								data-show-meridian="#currentProperty.timeMeridian#"
								<cfif len( thisDefaultValue )>value="#thisDefaultValue#"</cfif>
								<cfif len( currentProperty.placeholder )>placeholder="#currentProperty.placeholder#"</cfif>
								<cfif len( currentProperty.helpText )>title="#currentProperty.helpText#"</cfif>
								<cfif currentProperty.notNull>required="true"</cfif>
								<cfif len(currentProperty.validate)>pattern="#currentProperty.validate#"</cfif>
								type="text"/>
							<span class="input-group-addon"><i class="glyphicon glyphicon-time"></i></span>
						</div>
						<!--- help text HTML --->
						#helpTextHTML#
					 </div>
				<!--- TEXTTYPES --->
				<cfelse>
					<div class="col-sm-10">
					<cfswitch expression="#currentProperty.html#" >
						<!---Textarea --->
						<cfcase value="textarea">
							<textarea name="#currentProperty.name#"
									id="#currentProperty.name#"
									rows="10"
									class="form-control"
									<cfif len( currentProperty.helpText)>title="#currentProperty.helpText#"</cfif>
									<cfif currentProperty.notNull>required="true"</cfif>
								 	>#thisDefaultValue#</textarea>
						</cfcase>
						<!---RichText --->
						<cfcase value="richtext">
							<textarea name="#currentProperty.name#"
								  id="#currentProperty.name#"
								  rows="10"
								  <cfif len( currentProperty.helpText)>title="#currentProperty.helpText#"</cfif>
								  class="rte-zone form-control">#thisDefaultValue#</textarea>
						</cfcase>
						<!---HTML5 types --->
						<cfcase value="text,email,url,password" >
							<cfscript>
								options = [];
								if( len( currentProperty.options ) ){
									options = listToArray( currentProperty.options );
								}
								if( len( currentProperty.optionsUDF ) ){
									options = invoke( prc.oEntity, "#currentProperty.optionsUDF#" );
								}
							</cfscript>

							<!--- DB Options --->
							<cfif arrayLen( options )>
								<select name="#currentProperty.name#" id="#currentProperty.name#" class="form-control"
									    <cfif len( currentProperty.helpText )>title="#currentProperty.helpText#"</cfif>
									    <cfif currentProperty.notNull>required="true"</cfif>
								>
									#html.options( values=options, selectedValue="#thisDefaultValue#" )#
								</select>
							<cfelse>
								<input type="#currentProperty.html#"
									   name="#currentProperty.name#"
									   id="#currentProperty.name#"
									   class="form-control"
									   size="50"
									   <cfif len( thisDefaultValue )>value="#thisDefaultValue#"</cfif>
									   <cfif len( currentProperty.placeholder )>placeholder="#currentProperty.placeholder#"</cfif>
									   <cfif len( currentProperty.helpText )>title="#currentProperty.helpText#"</cfif>
									   <cfif currentProperty.notNull>required="true"</cfif>
									   <cfif len(currentProperty.validate)>pattern="#currentProperty.validate#"</cfif>
									   />
							</cfif>

						</cfcase>
						<!--- default --->
						<cfdefaultcase>
							<input type="text"
								 name="#currentProperty.name#"
								 id="#currentProperty.name#"
								 class="form-control"
								 size="50"
								 <cfif len( thisDefaultValue )>value="#thisDefaultValue#"</cfif>
								 <cfif len( currentProperty.placeholder )>placeholder="#currentProperty.placeholder#"</cfif>
								 <cfif len( currentProperty.helpText )>title="#currentProperty.helpText#"</cfif>
								 <cfif currentProperty.notNull>required="true"</cfif>
								 <cfif len(currentProperty.validate)>
								 	pattern="#currentProperty.validate#"
								 </cfif> />
						</cfdefaultcase>

					</cfswitch>

					<!--- Help Text --->
					#helpTextHTML#

					</div> <!--- end group --->

				</cfif>
			</div>
			</cfif>
		</cfloop>
	</fieldset>
	</div>

	<!---Form Actions --->
	<div class="form-actions well well-sm text-right">
		<!--- Mandatory Label --->
		<p class="col-sm-2"><span class="label label-warning">#getResource('db_form_required@db')#</span></p>

		<!---Button Bar --->
		<div id="buttonBar">
			<button type="submit" class="btn btn-danger">#getResource('db_general_save@db')#</button>
			<a href="#event.buildLink(prc.xehEntityList)#/#rc.safeEntity#" class="btn btn-default">#getResource('db_general_cancel@db')#</a>
		</div>

		<!---Loader --->
		<div id="loaderBar" style="display:none">
			<p>
				#getResource('db_general_wait@db')#<br />
				<img src="#prc.modRoot#includes/images/ajax-loader-horizontal.gif" align="absmiddle">
				<img src="#prc.modRoot#includes/images/ajax-loader-horizontal.gif" align="absmiddle">
			</p>
		</div>
	</div>
	<br />

#html.endForm()#
</cfoutput>