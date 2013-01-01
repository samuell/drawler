setup_sql:
	mysql -u drawler --password=drawler drawler < dbschema.sql

build:
	dmd drawler.d arsd/mysql.d arsd/database.d -L-lphobos2 -L-lcurl -version=MySQL_51

run: build
	./drawler http://saml.rilspace.org
