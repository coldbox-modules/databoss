component 
	persistent="true" 
	db_sortBy="label"
{

	// Some properties
	property 	name="id" 
				column="roleID" 
				fieldType="id" 
				generator="native" 
				db_labelText="Primary Key";

	property 	name="label" 
				column="roleLabel" 
				notnull="true" 
				length="50";

	property 	name="isActive"
				ormtype="boolean"
				sqltype="bit"
				notnull="true"
				default="false"
				dbdefault="0";

}