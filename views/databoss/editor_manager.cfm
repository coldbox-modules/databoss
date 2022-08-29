<!---
********************************************************************************
Copyright 2012 Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
--->
<cfoutput>

<!---MessageBox --->
<cfif flash.exists( "notice" )>
	<div class="alert alert-dismissable alert-#flash.get( "notice" ).type#">
		 <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
		 #flash.get( "notice" ).message#
	</div>
</cfif>

<!--- Add Form --->
#html.startForm( name="entityForm", action="#prc.xehEntityList#/#rc.entity#/doUpdate", class="form-horizontal", role="form", ssl=event.isSSL() )#
	<!--- hidden entity --->
	#html.hiddenField( name="entity", value="#rc.entity#" )#
	<!--- Primary Key Value --->
	#html.hiddenField( name="id", value=prc.pkValue )#
	<!--- Return URL Value --->
	#html.hiddenField( name="rURL", value=HTMLEditFormat( rc.rURL ) )#

	<div id="lookupFields">
	<fieldset>
		<br>

		<!--- Primary Key --->
		<div class="form-group">
			<label class="primaryKeyLabel col-sm-2 control-label">#prc.mdDictionary.pk.label#:</label>
			<div class="col-sm-10">
				<span class="label label-success">#htmlEditFormat( prc.pkValue )#</span>
			</div>
		</div>

		<!--- Loop Through Singular Relations, to create Drop Downs --->
		<cfloop from="1" to="#arrayLen( prc.mdDictionary.singularRelations )#" index="i">
			<!--- get reference to the listing of this lookup --->
			<cfset listing = prc[ "#prc.mdDictionary.singularRelations[ i ].alias#" ]>

			<!--- Check if it has it's value set, incase of null --->
			<cfif NOT invoke( prc.oEntity, "has#prc.mdDictionary.singularRelations[ i ].alias#" )>
				<cfset tmpValue = "">
			<cfelse>
				<cfset tmpValue = evaluate( "prc.oEntity.get#prc.mdDictionary.singularRelations[ i ].alias#().get#prc.mdDictionary.singularRelations[ i ].PK.name#()" )>
			</cfif>

			<div class="form-group">
				<!--- Singular Relation Label --->
				<label class="col-sm-2 control-label" for="fk_#prc.mdDictionary.singularRelations[ i ].alias#">#prc.mdDictionary.singularRelations[ i ].labelText#</label>
				<div class="col-sm-10">
					<!--- Singular Relation Data --->
					<select name="fk_#prc.mdDictionary.singularRelations[ i ].alias#"
							id="fk_#prc.mdDictionary.singularRelations[ i ].alias#"
							class="form-control"
							<cfif prc.mdDictionary.singularRelations[ i ].notNull>required="true"</cfif>>
						<option <cfif tmpValue eq "">selected="selected"</cfif> value="null"></option>
						<cfloop array="#Listing#" index="thisItem">
							<cfset thisItemPK = invoke( thisItem, "get#prc.mdDictionary.singularRelations[ i ].PK.name#" )>
							<option value="#thisItemPK#"
								<cfif thisItemPK eq tmpValue>selected</cfif>>
								#prc.entityDisplayHelper.buildDisplayColumns( prc.oEntity, prc.mdDictionary.singularRelations[ i ], thisItem )#
							</option>
						</cfloop>
					</select>

					<!--- is it oneToOne --->
					<cfif prc.mdDictionary.singularRelations[ i ].isOneToOne and tmpValue neq "">
						<cfset relationArray = [ invoke( prc.oEntity, "get#prc.mdDictionary.singularRelations[ i ].alias#()" ) ]>
						<br/><br/>
						<div class="well well-sm">
							<h3>#prc.mdDictionary.singularRelations[ i ].alias# #getResource('db_relationship_snapshot@db')#</h3>
							#html.table( data=relationArray, class="table table-condensed table-striped table-hover" )#
						</div>
					</cfif>
				</div>
			</div>

		</cfloop>

		<!--- Loop through Fields --->
		<cfloop from="1" to="#arrayLen( prc.mdDictionary.properties )#" index="i">
			<cfset currentProperty = prc.mdDictionary.properties[ i ] />

			<!--- Set value --->
			<cfset tmpValue = invoke( prc.oEntity, "get#currentProperty.name#" )>
			<cfif isNull( tmpValue )><cfset tmpValue = ""></cfif>
			<!--- Help Text --->
			<cfset helpTextHTML = "">
			<cfif len( currentProperty.helpText )>
				<cfset helpTextHTML = '<p class="help-block">#currentProperty.helpText#</p>'>
			</cfif>

			<div class="form-group">

				<!--- non updatable property --->
				<cfif currentProperty.update and currentProperty.displayUpdate>
					<!--- PROPERTY LABEL --->
					<label class="col-sm-2 control-label" for="#currentProperty.name#">
						#currentProperty.labelText#
						<cfif currentProperty.notNull><span class="text-error">*</span></cfif>
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
										<cfif isBoolean( tmpValue ) and tmpValue>checked="checked"</cfif> />
								</label>

								<label class="radio">#getResource('db_general_no@db')#
									<input type="radio"
									   name="#currentProperty.name#"
									   id="#currentProperty.name#"
									   value="0"
									   <cfif isBoolean( tmpValue ) and not tmpValue>checked="checked"</cfif> />
								</label>
							<cfelseif currentProperty.html eq "select">
								<select name="#currentProperty.name#"
										id="#currentProperty.name#"
										class="booleanSelect form-control">
									<option value="1" <cfif isBoolean( tmpValue ) and tmpValue>selected="selected"</cfif>>#getResource('db_general_true@db')#</option>
									<option value="0" <cfif isBoolean( tmpValue ) and not tmpValue>selected="selected"</cfif>>#getResource('db_general_false@db')#</option>
								</select>
							<cfelse>
								<div class="btn-group" data-toggle="buttons">
									<label class="btn btn-default<cfif isBoolean( tmpValue ) and tmpValue> active</cfif>">
									    <input
									    	type="radio"
									    	name="#currentProperty.name#"
									    	id="option1"
									    	value="1"
									    	<cfif isBoolean( tmpValue ) and tmpValue>checked="checked"</cfif>> #getResource('db_general_yes@db')#
									</label>
									<label class="btn btn-default<cfif isBoolean( tmpValue ) and !tmpValue> active</cfif>">
									    <input
									    	type="radio"
									    	name="#currentProperty.name#"
									    	id="option2"
									    	value="0"
									    	<cfif isBoolean( tmpValue ) and !tmpValue>checked="checked"</cfif>> #getResource('db_general_no@db')#
									</label>
							    </div>
							</cfif>
							<!--- help text HTML --->
							#helpTextHTML#
						</div>
					<!--- DATE TYPE --->
					<cfelseif currentProperty.datatype eq "date">
						<!--- date format --->
						<cfif len( currentProperty.dateformat )>
							<cfset thisDateValue = dateFormat( tmpValue, currentProperty.dateformat )>
						<cfelse>
							<cfset thisDateValue = dateFormat( tmpValue, "mm/dd/yyyy" )>
						</cfif>

						<!--- time format --->
						<cfif len( prc.mdDictionary.properties[ i ].timeformat )>
							<cfset thisTimeValue = timeFormat( tmpValue, prc.mdDictionary.properties[ i ].timeFormat )>
						<cfelse>
							<cfset thisTimeValue = timeFormat( tmpValue )>
						</cfif>

						<!---HTML Types --->
						<cfswitch expression="#currentProperty.html#" >

							<cfcase value="time">
								<div class="col-sm-3">
									<div class="input-group">
										<input id="#currentProperty.name#"
											name="#currentProperty.name#"
											class="clockpicker form-control"
											value="#thisTimeValue#"
											data-show-seconds="#currentProperty.timeSeconds#"
											data-show-meridian="#currentProperty.timeMeridian#"
											<cfif len( currentProperty.placeholder )>placeholder="#currentProperty.placeholder#"</cfif>
											<cfif len( currentProperty.helpText )>title="#currentProperty.helpText#"</cfif>
											<cfif currentProperty.notNull>required="true"</cfif>
											<cfif len(currentProperty.validate)>pattern="#currentProperty.validate#"</cfif>
											type="text"/>
										<span class="input-group-addon"><i class="glyphicon glyphicon-time"></i></span>
									</div>
									<!--- help text --->
									#helpTextHTML#
								</div>
							</cfcase>

							<cfcase value="datetime">
								<div class="col-sm-3">
									<!--- hidden value.  This always uses a standard format regardless of the funky formats the display might use --->
									<input type="hidden" name="#currentProperty.name#" id="#currentProperty.name#" value="#dateFormat( tmpValue, "YYYY-MM-DD" )# #thisTimeValue#" >

									<div class="input-group">
										<input type="text"
											size="20"
											value="#thisDateValue#"
											<cfif len( currentProperty.dateFormat )>data-date-format="#currentProperty.dateFormat#"</cfif>
											name="#currentProperty.name#-dField"
											id="#currentProperty.name#-dField"
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
											value="#thisTimeValue#"
											data-show-seconds="#currentProperty.timeSeconds#"
											data-show-meridian="#currentProperty.timeMeridian#"
											<cfif len( currentProperty.placeholder )>placeholder="#currentProperty.placeholder#"</cfif>
											<cfif len( currentProperty.helpText )>title="#currentProperty.helpText#"</cfif>
											<cfif currentProperty.notNull>required="true"</cfif>
											<cfif len(currentProperty.validate)>pattern="#currentProperty.validate#"</cfif>
											type="text"
											onchange="updateDTField( '#currentProperty.name#' )"/>
										<span class="input-group-addon"><i class="glyphicon glyphicon-time"></i></span>
									</div>

									<!--- help text --->
									#helpTextHTML#
								</div>
							</cfcase>

							<cfdefaultcase>
								<div class="col-sm-3">
									<div class="input-group">
										<input type="text"
											size="20"
											value="#thisDateValue#"
											<cfif len( currentProperty.dateFormat )>data-date-format="#currentProperty.dateFormat#"</cfif>
											name="#currentProperty.name#"
											id="#currentProperty.name#"
											<cfif len( currentProperty.helpText)>title="#currentProperty.helpText#"</cfif>
											<cfif currentProperty.notNull>required="true"</cfif>
											class="datepicker form-control"/>
										<span class="input-group-addon"><i class="glyphicon glyphicon-calendar"></i></span>
									</div>
									<!--- help text --->
									#helpTextHTML#
								</div>

							</cfdefaultcase>

						</cfswitch>

					<!--- String Time picker --->
					<cfelseif currentProperty.html eq "time">
						<div class="bootstrap-clockpicker col-sm-3">
							<div class="input-group">
								<input id="#currentProperty.name#"
									name="#currentProperty.name#"
									class="clockpicker form-control"
									value="#tmpValue#"
									data-show-seconds="#currentProperty.timeSeconds#"
									data-show-meridian="#currentProperty.timeMeridian#"
									<cfif len( currentProperty.placeholder )>placeholder="#currentProperty.placeholder#"</cfif>
									<cfif len( currentProperty.helpText )>title="#currentProperty.helpText#"</cfif>
									<cfif currentProperty.notNull>required="true"</cfif>
									<cfif len(currentProperty.validate)>pattern="#currentProperty.validate#"</cfif>
									type="text"
									onclick="$('###currentProperty.name#').clockpicker('showWidget')"/>
								<span class="input-group-addon"><i class="glyphicon glyphicon-time"></i></span>
							</div>
							<!--- help text HTML --->
							#helpTextHTML#
						 </div>
					<!--- Other Types --->
					<cfelse>
						<!--- Default Property Type --->
						<cfset thisPropertyType = currentProperty.html>
						<!--- Len and Text Check Overrides --->
						<cfif currentProperty.html eq "text" and len( tmpValue ) GT 150>
							<cfset thisPropertyType = "textarea">
						</cfif>
						<div class="col-sm-10">
							<!---Property Types --->
							<cfswitch expression="#thisPropertyType#" >
								<!---Textarea --->
								<cfcase value="textarea">
									<textarea name="#currentProperty.name#"
										id="#currentProperty.name#"
										rows="10"
										class="form-control"
										<cfif len( currentProperty.helpText)>title="#currentProperty.helpText#"</cfif>
										<cfif currentProperty.notNull>required="true"</cfif>>#tmpValue#</textarea>
								</cfcase>
								<!---RichText --->
								<cfcase value="richtext">
									<textarea name="#currentProperty.name#"
										id="#currentProperty.name#"
										class="rte-zone form-control"
										rows="10"
										<cfif len( currentProperty.helpText)>title="#currentProperty.helpText#"</cfif>
										<cfif currentProperty.notNull>required="true"</cfif>>#tmpValue#</textarea>
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
											#html.options( values=options, selectedValue="#tmpValue#" )#
										</select>
									<cfelse>
										<input type="#currentProperty.html#"
										   		name="#currentProperty.name#"
										   		id="#currentProperty.name#"
										   		value="#tmpValue#"
										   		size="50"
												class="form-control"
												<cfif len( currentProperty.helpText)>title="#currentProperty.helpText#"</cfif>
										   		<cfif currentProperty.notNull>required="true"</cfif>
										   		<cfif len(currentProperty.validate)>
													pattern="#currentProperty.validate#"
												</cfif>
											/>
									</cfif>
								</cfcase>
								<!--- default --->
								<cfdefaultcase>
									<input type="text"
										 name="#currentProperty.name#"
										 id="#currentProperty.name#"
										 class="form-control"
										 value="#tmpValue#"
										 size="50"
										 <cfif len( currentProperty.helpText)>title="#currentProperty.helpText#"</cfif>
										 <cfif currentProperty.notNull>required="true"</cfif>
										 <cfif len(currentProperty.validate)>
										 	pattern="#currentProperty.validate#"
										 </cfif> />
								</cfdefaultcase>
							</cfswitch>
							<!--- help text HTML --->
							#helpTextHTML#
						</div>
					</cfif>

				</cfif>

			</div> <!---end control group --->
		</cfloop>
	</fieldset>
	</div>

	<!---Form Actions --->
	<cfif !prc.export>
	<div class="form-actions well well-sm text-right">
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
	</cfif>
#html.endForm()#
</cfoutput>