setup_sql:
	mysql -u drawler --password=drawler drawler < dbschema.sql

build: setup_sql
	dmd drawler.d arsd/mysql.d arsd/database.d -gc -L-lphobos2 -L-lcurl -version=MySQL_51

run: build
	time { ./drawler http://saml.rilspace.org; echo "-----"; }
