#!/bin/env bash

shopt -s extglob
set -x #echo on for debugging (comment to disable)

function main() {

	# the directory of the script
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# the temp directory used, within $DIR
	# omit the -p parameter to create a temporal directory in the default location

	mkdir downloads
	DOWNLOAD_DIR=downloads

	WORK_DIR=`mktemp -d -p "$DIR"`
	#mkdir data
	#WORK_DIR=data

	# check if tmp dir was created
	if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
	  echo "Could not create temp dir"
	  exit 1
	fi

	# deletes the temp directory
	function cleanup {      
	  rm -rf "$WORK_DIR"
	  echo "Deleted temp working directory $WORK_DIR"
	}

	# register the cleanup function to be called on the EXIT signal
	trap cleanup EXIT

	# implementation of script starts here

	# Database and server information
	DBHOST="localhost"
	DBPORT="5432"
	DBUSER="geonames"
	GEONAMESDB="geonames"

	BASE_DIR=$(dirname "${BASH_SOURCE[0]}")

	# Change these for your local system
	WGET="/bin/wget"
	PSQL="/bin/psql -q"
	UNZIP="/bin/unzip"
	SED="/bin/sed"
	OGR2OGR="/bin/ogr2ogr"

	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/allCountries.zip -O $DOWNLOAD_DIR/geonames-allCountries.zip 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/alternateNamesV2.zip 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/countryInfo.txt 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/admin1CodesASCII.txt 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/admin2Codes.txt 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/timeZones.txt 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/userTags.zip 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/hierarchy.zip 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/adminCode5.zip 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/featureCodes_en.txt 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/featureCodes_bg.txt 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/featureCodes_nb.txt 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/featureCodes_nn.txt 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/featureCodes_no.txt 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/featureCodes_ru.txt 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/featureCodes_sv.txt 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/dump/shapes_simplified_low.json.zip 
	$WGET -c -P $DOWNLOAD_DIR http://download.geonames.org/export/zip/allCountries.zip -O $DOWNLOAD_DIR/postalcodes-allCountries.zip 

	$UNZIP $DOWNLOAD_DIR/geonames-allCountries.zip -d $WORK_DIR
	mv $WORK_DIR/allCountries.txt $WORK_DIR/geonames-allCountries.txt
	$UNZIP $DOWNLOAD_DIR/alternateNamesV2.zip -d $WORK_DIR
	$UNZIP $DOWNLOAD_DIR/hierarchy.zip -d $WORK_DIR
	$UNZIP $DOWNLOAD_DIR/adminCode5.zip -d $WORK_DIR
	$UNZIP $DOWNLOAD_DIR/postalcodes-allCountries.zip -d $WORK_DIR
	mv $WORK_DIR/allCountries.txt $WORK_DIR/postalcodes-allCountries.txt
	$UNZIP $DOWNLOAD_DIR/userTags.zip -d $WORK_DIR
	$UNZIP $DOWNLOAD_DIR/shapes_simplified_low.json.zip -d $WORK_DIR
	cp $DOWNLOAD_DIR/countryInfo.txt $WORK_DIR/
	cp $DOWNLOAD_DIR/admin1CodesASCII.txt $WORK_DIR/
	cp $DOWNLOAD_DIR/admin2Codes.txt $WORK_DIR/
	cp $DOWNLOAD_DIR/timeZones.txt $WORK_DIR/
	cp $DOWNLOAD_DIR/featureCodes_en.txt $WORK_DIR/
	cp $DOWNLOAD_DIR/featureCodes_bg.txt $WORK_DIR/
	cp $DOWNLOAD_DIR/featureCodes_nb.txt $WORK_DIR/
	cp $DOWNLOAD_DIR/featureCodes_nn.txt $WORK_DIR/
	cp $DOWNLOAD_DIR/featureCodes_no.txt $WORK_DIR/
	cp $DOWNLOAD_DIR/featureCodes_ru.txt $WORK_DIR/
	cp $DOWNLOAD_DIR/featureCodes_sv.txt $WORK_DIR/

	$SED -i -e '/^#/d' $WORK_DIR/countryInfo.txt
	$SED -i -e 's/\\//' $WORK_DIR/postalcodes-allCountries.txt

	$SED -i -e 's/\t/\ten\t/' $WORK_DIR/featureCodes_en.txt
	$SED -i -e 's/\t/\tbg\t/' $WORK_DIR/featureCodes_bg.txt
	$SED -i -e 's/\t/\tnb\t/' $WORK_DIR/featureCodes_nb.txt
	$SED -i -e 's/\t/\tnn\t/' $WORK_DIR/featureCodes_nn.txt
	$SED -i -e 's/\t/\tno\t/' $WORK_DIR/featureCodes_no.txt
	$SED -i -e 's/\t/\tru\t/' $WORK_DIR/featureCodes_ru.txt
	$SED -i -e 's/\t/\tsv\t/' $WORK_DIR/featureCodes_sv.txt

	cp $BASE_DIR/geonames-continents.txt $WORK_DIR/

	# Make the tables
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -f "$BASE_DIR/geonames-schema.sql"

	# Geoname table
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy geoname FROM $WORK_DIR/geonames-allCountries.txt NULL AS '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "ALTER TABLE geoname ADD PRIMARY KEY (geonameid);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "ALTER TABLE geoname ADD COLUMN fclasscode varchar(12);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "UPDATE geoname SET fclasscode = concat(fclass, '.', fcode);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "SELECT AddGeometryColumn( 'geoname', 'the_geom', 4326, 'POINT', 2);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "UPDATE geoname SET the_geom = ST_PointFromText('POINT(' || longitude || ' ' || latitude || ')', 4326);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "CREATE INDEX geoname_fcode ON geoname(fcode);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "CREATE INDEX geoname_adminx ON geoname(admin1, admin2, admin3, admin4);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "CREATE INDEX geoname_the_geom_gist_idx ON geoname using gist (the_geom);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "CREATE INDEX geoname_geonameid_idx ON geoname(geonameid);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "CREATE INDEX geoname_name_idx ON geoname(name);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "CREATE INDEX geoname_fclass_idx ON geoname(fclass);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "VACUUM FULL geoname;"

	# alternateNames table
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy alternatename from $WORK_DIR/alternateNamesV2.txt null as '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "ALTER TABLE alternatename ADD PRIMARY KEY (alternatenameid);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "CREATE INDEX alternatename_geonameid_idx ON alternatename(geonameid);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "VACUUM ANALYZE alternatename;"

	# isolanguagecodes
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy isolanguagecode FROM $WORK_DIR/iso-languagecodes.txt NULL '' delimiter E'\t' csv header;"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "VACUUM ANALYZE isolanguagecode;"

	# countryinfo
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy countryinfo FROM $WORK_DIR/countryInfo.txt NULL AS '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "ALTER TABLE countryinfo ADD PRIMARY KEY (geonameid);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "VACUUM ANALYZE countryinfo;"

	# timezones
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy timezones FROM $WORK_DIR/timeZones.txt NULL '' delimiter E'\t' csv header;"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "ALTER TABLE timezones ADD PRIMARY KEY (timezoneid);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "create index timezones_countrycode_idx on timezones(countrycode);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze timezones;"

	# admin1codesascii
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy admin1codesascii FROM $WORK_DIR/admin1CodesASCII.txt NULL AS '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "create index admin1codesascii_geonameid_idx on admin1codesascii(geonameid);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze admin1codesascii;"

	# admin2codes
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy admin2codes FROM $WORK_DIR/admin2Codes.txt NULL AS '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "create index admin2codes_geonameid_idx on admin2codes(geonameid);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze admin2codes;"

	# featurecodes
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy featurecodes FROM $WORK_DIR/featureCodes_bg.txt NULL AS '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy featurecodes FROM $WORK_DIR/featureCodes_en.txt NULL AS '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy featurecodes FROM $WORK_DIR/featureCodes_nb.txt NULL AS '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy featurecodes FROM $WORK_DIR/featureCodes_nn.txt NULL AS '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy featurecodes FROM $WORK_DIR/featureCodes_no.txt NULL AS '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy featurecodes FROM $WORK_DIR/featureCodes_ru.txt NULL AS '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy featurecodes FROM $WORK_DIR/featureCodes_sv.txt NULL AS '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "ALTER TABLE featurecodes ADD PRIMARY KEY (code, lang);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "VACUUM ANALYZE featurecodes;"

	# usertags
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy usertags FROM $WORK_DIR/userTags.txt NULL AS '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "CREATE INDEX usertags_geonameid_idx ON usertags(geonameid);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "VACUUM ANALYZE usertags;"

	# hierarchy
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy hierarchy from $WORK_DIR/hierarchy.txt null as '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "CREATE INDEX hierarchy_idx ON hierarchy(parentid, childid);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "VACUUM ANALYZE hierarchy;"

	# admincode5
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy admincode5 from $WORK_DIR/adminCode5.txt null as '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "ALTER TABLE admincode5 ADD PRIMARY KEY (geonameid);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "VACUUM ANALYZE admincode5;"

	# usertags
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy usertags FROM $WORK_DIR/userTags.txt NULL AS '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "CREATE INDEX usertags_idx ON usertags(geonameid);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "VACUUM ANALYZE usertags;"

	# postalcodes
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "\copy postalcodes from $WORK_DIR/postalcodes-allCountries.txt null as '';"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "create index postalcodes_idx on postalcodes(postalcode, countrycode);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze postalcodes;"

	# continent
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "INSERT INTO continentCodes VALUES ('AF', 'Africa', 6255146);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "INSERT INTO continentCodes VALUES ('AS', 'Asia', 6255147);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "INSERT INTO continentCodes VALUES ('EU', 'Europe', 6255148);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "INSERT INTO continentCodes VALUES ('NA', 'North America', 6255149);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "INSERT INTO continentCodes VALUES ('OC', 'Oceania', 6255150);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "INSERT INTO continentCodes VALUES ('SA', 'South America', 6255151);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "INSERT INTO continentCodes VALUES ('AN', 'Antarctica', 6255152);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "ALTER TABLE continentinfo ADD PRIMARY KEY (geonameid);"
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze continentinfo;"

	# shapes
	$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "DROP TABLE IF EXISTS shapessimplifiedlow";
	$OGR2OGR -f "PostgreSQL" PG:"dbname=$GEONAMESDB user=$DBUSER" $WORK_DIR/shapes_simplified_low.json -nln shapessimplifiedlow -overwrite


	##TODO add foreign keys
}

main $@
