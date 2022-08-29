component persistent="true" db_sortBy="label"{

	// Some properties
	property 	name="id" 
				column="titleID" 
				fieldType="id" 
				generator="native";

	property 	name="label" 
				notnull="true"
				length="100";

}