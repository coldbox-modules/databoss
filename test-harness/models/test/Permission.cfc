component persistent="true" db_sortBy="label"{
	
	// Some properties
	property 	name="id" 
				column="permissionID" 
				fieldType="id" 
				generator="native" 
				db_labelText="Primary Key";
	
	property 	name="label" 
				column="permissionLabel" 
				notnull="true" 
				length="50" 
				db_helpText="The Permission Label";
				
	property 	name="description" 
				column="permissionDescription" 
				ormtype="text" 
				db_html="richtext" 
				db_helpText="Permission description data";

	property 	name="isActive" 
				column="isActive" 
				ormtype="boolean" 
				notnull="true" 
				update="true" 
				dbdefault="1" 
				default="true" 
				db_helpText="Permission activation bit";
	
}