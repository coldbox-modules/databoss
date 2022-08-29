/**
* A user option
*/
component persistent="true" {

	property 	name="id" 
				column="optionID" 
				fieldtype="id" 
				generator="native";
	
	property 	name="User" 
				fieldtype="one-to-one" 
				cfc="User" 
				fkcolumn="FK_baseID" 
				db_displayColumns="fname,lname";
	
	property 	name="homePage" 
				default="home" 
				dbdefault="'home'";
				
	property 	name="showWelcome" 
				default="true" 
				dbdefault="1" 
				ormType="boolean";
	
}