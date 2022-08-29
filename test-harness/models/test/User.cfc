component 
	persistent="true" 
	extends="BaseEntity" 
	joincolumn="id" 
	db_sortBy="email"
{

	// Some properties
	property
		name="fname"
		column="firstName"
		length="50"
		notnull="true"
		db_helpText="The first name";

	property
		name="lname"
		column="lastName"
		length="50"
		notnull="true"
		db_helpText="The last name";

	property
		name="email"
		column="email"
		length="250"
		notnull="false"
		db_helpText="The E-mail";

	property
		name="dob"
		ormtype="date"
		db_dateformat="dd-mm-yyyy"
		db_showDate="true"
		db_showTime="false"
		db_html="date"
		db_helpText="The date of birth";

	property
		name="dobtime" db_labelText="Time of Birth"
		notnull="false"
		db_html="time"
		db_timeSeconds=false
		db_timeMeridian=true
		db_helpText="The Time of birth";

	property
		name="color"
		column="color"
		length="200"
		notnull="false"
		db_display="false"
		db_options="red,white,blue"
		db_helpText="The Color";

	property
		name="color2"
		column="color2"
		length="200"
		notnull="false"
		db_display="false"
		db_optionsUDF="getColors"
		db_helpText="The other color";

	property
		name="notes"
		column="notes"
		ormtype="text"
		db_display="false"
		db_html="richtext"
		db_helpText="The notes";

	// Many to One
	property
		name="role"
		fieldType="many-to-one"
		cfc="Role"
		fkcolumn="FK_roleID"
		lazy="true"
		cascade="all"
		db_displayColumns="label"
		db_helpText="The role";

	// Many to One Optional
	property
		name="title"
		fieldType="many-to-one"
		cfc="Title"
		fkcolumn="FK_titleID"
		lazy="true"
		cascade="all"
		notnull="false"
		db_displayColumns="label"
		db_helpText="The title";

	// Many To Many
	property name="permissions"
		fieldtype="many-to-many"
		cfc="Permission"
		lazy="true"
		cascade="all"
		linkTable="UserPermission"
		fkcolumn="baseID"
		inversejoincolumn="permissionID"
		db_helpText="The permissions"
		db_displayColumns="label";

	// One To Many
	property name="nicknames"
		fieldtype="one-to-many"
		cfc="Nickname"
		singularname="alias"
		fkColumn="FK_baseID"
		orderby="nickname"
		type="array"
		lazy="true"
		cascade="all-delete-orphan"
		inverse="true"
		db_helpText="The Nicknames";

	// one to One
	property name="AwesomeOptions"
		fieldtype="one-to-one"
		cfc="Option"
		mappedby="User"
		db_helpText="The Awesome Options";

	/**
	 * Constructor
	 */
	function init(){
		createDate = now();
	}

	/**
	* Get an array of colors
	*/
	function getColors(){
		return [ "green", "yellow", "black" ];
	}
}