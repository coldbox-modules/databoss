component persistent="true" db_sortBy="nickname"{

	// Some properties
	property name="id" column="nicknameID" fieldtype="id" generator="native";
	property name="nickname" column="nickname" length="50" notnull="true";

	// back to user
	property name="user"
		fieldtype="many-to-one"
		fkcolumn="FK_baseID"
		cfc="User"
		missingRowIgnored="true"
		db_displayColumns="fname,lname";

	this.memento = {
		defaultIncludes = [ "id", "nickname" ],
		defaultExcludes = [ "user" ]
	};
}