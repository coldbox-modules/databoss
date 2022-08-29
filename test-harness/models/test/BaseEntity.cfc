component persistent="true"{

	property 	name="id" 
				column="baseID" 
				fieldtype="id" 
				generator="native";

	// Some Auditing
	property 	name="createDate" 
				type="date" 
				ormType="timestamp" 
				update="false" 
				notnull="true" 
				db_helpText="The creation date";

	property 	name="updateDate" 
				ormType="timestamp" 
				sqltype="timestamp" 
				insert="false" 
				db_helpText="The update date";

}
