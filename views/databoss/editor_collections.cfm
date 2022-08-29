<!---
********************************************************************************
Copyright 2012 Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
--->
<cfoutput>
	<!--- Many To Many Relations --->
	<cfif prc.mdDictionary.hasCollections>

		<!--- ******************************************************************************** --->
		<!--- Many To Many --->
		<!--- ******************************************************************************** --->
		<cfloop from="1" to="#arrayLen( prc.mdDictionary.collections )#" index="relIndex">
			<cfif NOT prc.mdDictionary.collections[relIndex].isOneToMany>
				<cfset thisCollection = prc.mdDictionary.collections[relIndex]>
				<cfset listing = prc["#thisCollection.alias#"]>
				<cfset relationArray = prc["#thisCollection.alias#Array"]>
				<cfset relationDictionary = prc["#thisCollection.alias#Dictionary"]>
				<cfset labelText = thisCollection.labelText>

				<!--- Display Relation Form --->
				<form name="add#thisCollection.alias#Form" id="add#thisCollection.alias#Form"
				      action="#event.buildLink(prc.xehEntityList)#/#rc.entity#/doUpdateRelation" method="post"
				      class="well well-sm">

					<!--- Entity Class Choosen to Add --->
					<input type="hidden" name="entity" id="entity" value="#rc.entity#">
					<!--- Primary Key Value --->
					<input type="hidden" name="entityID" id="entityID" value="#prc.pkValue#">
					<!--- Relation Source --->
					<input type="hidden" name="relationSource" id="relationSource"
					       value="#thisCollection.sourceEntity#">
					<input type="hidden" name="relationAlias" id="relationAlias" value="#thisCollection.alias#">
					<!--- Action: 1 ADD, 0 Remove --->
					<input type="hidden" name="addRelation" id="addRelation" value="1">

					<fieldset>
						<legend>
							<a name="collection_#thisCollection.alias#">
							</a>
							<strong>
								#labelText#
							</strong>
							<span class="label label-default">
								#arrayLen(relationArray)#
							</span>
						</legend>

						<!--- Loader --->
						<div id="_loader_#thisCollection.alias#" class="loaderBar" style="display:none;">
							#getResource('db_general_submitting@db')#
							<br/>
							<img src="#prc.modRoot#includes/images/ajax-loader-horizontal.gif" align="absmiddle">
							<img src="#prc.modRoot#includes/images/ajax-loader-horizontal.gif" align="absmiddle">
						</div>
						<!--- Control Bar --->
						<cfif !prc.export>
							<div id="_buttonbar_#thisCollection.alias#">
								<div class="input-group">
									<!--- Collection Drop Down Listing --->
									<select name="collection_#thisCollection.alias#" id="collection_#thisCollection.alias#"
									        class="form-control input-sm">
										<cfloop array="#Listing#" index="thisItem">
											<cfset thisItemPK = invoke( thisItem, "get#thisCollection.PK.name#" )>
											<option value="#thisItemPK#">
												#prc.entityDisplayHelper.buildDisplayColumns( {}, thisCollection, thisItem )#
											</option>
										</cfloop>
									</select>

									<span class="input-group-btn">
										<!--- Add Button if we have Entries to show --->
										<cfif arrayLen( Listing ) >
											<a href="javascript:submitCollection('#thisCollection.alias#',1)"
											   class="btn btn-primary btn-sm">
												<i class="glyphicon glyphicon-plus icon-white">
												</i>
												<span class="hidden-sm hidden-xs inline">
													#getResource('db_relationship_add@db')#
												</span>
											</a>
										</cfif>

										<!--- Remove Button --->
										<cfif arraylen(relationArray)>
											<a href="javascript:submitCollection('#thisCollection.alias#',0)"
											   class="btn btn-danger btn-sm">
												<i class="glyphicon glyphicon-remove icon-white">
												</i>
												<span class="hidden-sm hidden-xs inline">
													#getResource('db_relationship_remove@db')#
												</span>
											</a>
										</cfif>
									</span>
								</div>
							</div>
						</cfif>

						<!--- Actual collection for this entity --->
						<cfif arraylen(relationArray)>
							<br>
							<table class="table table-striped table-hover" id="collection_#thisCollection.alias#_table"
							       width="98%">
								<thead>
									<tr>
										<th id="actions" class="{sorter: false} centered" width="100">
											Delete
										</th>
										<!--- All Other Fields --->
										<cfloop from="1" to="#ArrayLen( relationDictionary.properties )#" index="i">
											<cfif relationDictionary.properties[i].display>
												<th class="{sorter: 'text'}">
													#relationDictionary.properties[i].labelText#
												</th>
											</cfif>
										</cfloop>
										<!--- Singular Relationships --->
										<cfloop array="#relationDictionary.singularRelations#" index="thisRel">
											<cfif thisRel.display>
												<th class="{sorter: 'text'}">#thisRel.labelText#</th>
											</cfif>
										</cfloop>
									</tr>
								</thead>

								<!--- Loop Through Results --->
								<tbody>
									<cfloop array="#relationArray#" index="thisRow">
										<cfset thisRowID = invoke( thisRow, "get#relationDictionary.PK.name#" )>
										<tr>
											<!--- Display Commands --->
											<td class="centered">
												<cfset thisRelationPKID = invoke( thisRow, "get#thisCollection.pk.name#" )>
												<input type="checkbox" name="collection_#thisCollection.alias#_id"
													id="collection_#thisCollection.alias#_id" value="#thisRelationPKID#"/>
											</td>
											<!--- Loop Through Columns and their values --->
											<cfloop from="1" to="#arrayLen( relationDictionary.properties )#" index="i">
												<!---Get value and nullify checks --->
												<cfset thisValue = invoke( thisRow, "get#relationDictionary.properties[ i ].name#" )>
												<cfif isNull( thisValue )>
													<cfset thisValue = '<db:null>'>
												</cfif>
												<!---Don't show display eq false --->
												<cfif relationDictionary.properties[i].display>
													<td>
														<cfif relationDictionary.properties[i].datatype eq "boolean" and isBoolean( thisValue )>
															#yesnoFormat( thisValue )#
														<cfelseif relationDictionary.properties[i].datatype eq "date" and isDate( thisValue )>
															#dateFormat( thisValue )#
														<cfelseif thisValue eq "<db:null>">
															<span class="label label-warning"><em>null</em></span>
														<cfelse>
															#HTMLEditFormat( thisValue )#
														</cfif>
													</td>
												</cfif>
											</cfloop>
											<!--- Loop Singluar Relationship Data --->
											<cfloop array="#relationDictionary.singularRelations#" index="thisRel">
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
										</tr>
									</cfloop>
								</tbody>
							</table>
						<cfelse>
							<cfif !prc.export>
								<br>
								<div class="alert alert-warning">
									<h4 class="alert-heading">
										#getResource('db_general_oops@db')#
									</h4>
									#replace(getResource('db_relationship_norecords@db'), '{1}', thisCollection.alias)#
								</div>
							</cfif>
						</cfif>
					</fieldset>
				</form>
			</cfif>
		</cfloop>

		#html.startForm( name="entityDeleteForm", action=prc.xehEntityDelete, ssl=event.isSSL() )#
			#html.hiddenField( name="entity", id="delete_entity", value="" )#
			#html.hiddenField( name="entityID", id="delete_entityID", value="" )#
			#html.hiddenField( name="rURL", id="rURL", value=HTMLEditFormat( event.getCurrentRoutedURL() & "collection/true" ) )#
		#html.endForm()#

		<!--- ******************************************************************************** --->
		<!--- One To Many --->
		<!--- ******************************************************************************** --->
		<cfloop array="#prc.mdDictionary.collections#" index="thisCollection">
			<cfif thisCollection.isOneToMany>
				<cfset relationArray = prc["#thisCollection.alias#Array"]>
				<cfset relationDictionary = prc["#thisCollection.alias#Dictionary"]>
				<cfset labelText = thisCollection.labelText>
				<div class="well well-sm">
					<fieldset>

						<!---Legend --->
						<legend>
							<a name="collection_#thisCollection.alias#">
							</a>
							<strong>
								#labelText#
							</strong>
							<span class="label label-default">
								#arrayLen(relationArray)#
							</span>
							<cfif !prc.export>
								<!---Add Record --->
								<a class="btn btn-danger btn-sm pull-right" style="margin-right:10px"
								   href="#event.buildLink( linkto='databoss.entity.#thisCollection.sourceEntity#.create.#rc.entity#.#prc.pkvalue#' )#?rURL=#URLEncodedFormat( event.getCurrentRoutedURL() & "collection/true" )#">
									<i class="glyphicon glyphicon-plus icon-white">
									</i>
									#getResource('db_general_add@db')#
								</a>
							</cfif>
						</legend>

						<!--- Actual collection for this entity --->
						<cfif arraylen(relationArray)>
							<table class="table table-striped table-hover" id="collection_#thisCollection.alias#_table"
							       width="98%">
								<thead>
									<tr>
										<!--- All Other Fields --->
										<cfloop from="1" to="#ArrayLen( relationDictionary.properties )#" index="i">
											<cfif relationDictionary.properties[i].display>
												<th class="{sorter: 'text'}">
													#relationDictionary.properties[i].labelText#
												</th>
											</cfif>
										</cfloop>
										<!--- Singular Relationships --->
										<cfloop array="#relationDictionary.singularRelations#" index="thisRel">
											<cfif thisRel.display>
												<th class="{sorter: 'text'}">#thisRel.labelText#</th>
											</cfif>
										</cfloop>
										<th id="actions" class="{sorter: false} centered" width="100">
											Actions
										</th>
									</tr>
								</thead>

								<!--- Loop Through Results --->
								<tbody>
									<cfloop array="#relationArray#" index="thisRow">
										<cfset thisRowID = invoke( thisRow, "get#relationDictionary.PK.name#" )>
										<tr>
											<!--- Loop Through Columns and their values --->
											<cfloop from="1" to="#arrayLen( relationDictionary.properties )#" index="i">
												<!---Get value and nullify checks --->
												<cfset thisValue = invoke( thisRow, "get#relationDictionary.properties[ i ].name#" )>
												<cfif isNull( thisValue )>
													<cfset thisValue = '<db:null>'>
												</cfif>
												<!---Don't show display eq false --->
												<cfif relationDictionary.properties[ i ].display>
													<td>
														<cfif relationDictionary.properties[ i ].datatype eq "boolean" and isBoolean( thisValue )>
															#yesnoFormat( thisValue )#
														<cfelseif relationDictionary.properties[ i ].datatype eq "date" and isDate( thisValue )>
															#dateFormat( thisValue )#
														<cfelseif thisValue eq "<db:null>">
															<span class="label label-warning"><em>null</em></span>
														<cfelse>
															#HTMLEditFormat( thisValue )#
														</cfif>
													</td>
												</cfif>
											</cfloop>
											<!--- Loop Singluar Relationship Data --->
											<cfloop array="#relationDictionary.singularRelations#" index="thisRel">
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
											<!--- Display Commands --->
											<td class="centered">
												<!---Edit --->
												<a class="btn btn-sm btn-info" rel="tooltip" title="#getResource( 'db_record_edit@db' )#"
												   href="#event.buildLink( prc.xehEntityList )#/#thisCollection.sourceEntity#/id/#thisRowID#?rURL=#URLEncodedFormat( event.getCurrentRoutedURL() & "collection/true" )#">
													<i class="glyphicon glyphicon-edit icon-white">
													</i>
												</a>
												<!---Delete --->
												<a class="btn btn-small btn-danger" rel="tooltip"
												   title="#getResource( 'db_record_remove@db' )#"
												   href="javascript:confirmDelete( '#thisCollection.sourceEntity#', '#thisRowID#' )">
													<i class="glyphicon glyphicon-remove icon-white">
													</i>
												</a>
											</td>
										</tr>
									</cfloop>
								</tbody>
							</table>
						<cfelse>
							<cfif !prc.export>
								<div class="alert alert-danger">
									<h4 class="alert-heading">
										#getResource('db_general_oops@db')#
									</h4>
									#replace(getResource('db_relationship_none@db'), '{1}', thisCollection.alias)#
									<a href="#event.buildLink('databoss.entity.#thisCollection.sourceEntity#.create')#">
										#getResource('db_record_create@db')#
									</a>
									#getResource('db_record_create_now@db')#
								</div>
							</cfif>
						</cfif>
					</fieldset>
				</div>
			</cfif>
		</cfloop>

	<cfelse>

		<div class="alert alert-warning">
			<img src="#prc.modRoot#includes/images/warning.png" alt="warning"/>
			#getResource('db_relationship_no_collections@db')#
		</div>
	</cfif>
</cfoutput>