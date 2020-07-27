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
	mkdir $DOWNLOAD_DIR

	WORK_DIR=`mktemp -d -p "$DIR"`

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
	GEONAMESDB="geonames.sqlite3"

	BASE_DIR=$(dirname "${BASH_SOURCE[0]}")

	# Change these for your local system
	WGET="/bin/wget"
	SQLITE3="/usr/local/bin/sqlite3"
	UNZIP="/bin/unzip"
	SED="/bin/sed"
	OGR2OGR="/bin/ogr2ogr"

	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/allCountries.zip -O $DOWNLOAD_DIR/geonames-allCountries.zip 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/alternateNamesV2.zip 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/countryInfo.txt 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/admin1CodesASCII.txt 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/admin2Codes.txt 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/timeZones.txt 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/userTags.zip 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/hierarchy.zip 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/adminCode5.zip 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/featureCodes_en.txt 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/featureCodes_bg.txt 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/featureCodes_nb.txt 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/featureCodes_nn.txt 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/featureCodes_no.txt 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/featureCodes_ru.txt 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/featureCodes_sv.txt 
	$WGET -c -P $DOWNLOAD_DIR https://download.geonames.org/export/dump/shapes_simplified_low.json.zip 
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

	# Make the tables
	$SQLITE3 $GEONAMESDB < "$BASE_DIR/geonames-schema.sql"

	# timezones
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/timeZones.txt timezones"
	#$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<"ALTER TABLE timezones ADD PRIMARY KEY (timezoneid);"
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<"create index timezones_countrycode_idx on timezones(countrycode);"

	# Geoname table
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/geonames-allCountries.txt geoname"
	$SQLITE3 $GEONAMESDB <<<"ALTER TABLE geoname ADD PRIMARY KEY (geonameid);"
	$SQLITE3 $GEONAMESDB <<<"ALTER TABLE geoname ADD FOREIGN KEY (timezone) REFERENCES timezones(timezoneid);"
	$SQLITE3 $GEONAMESDB <<<"ALTER TABLE geoname ADD COLUMN fclasscode varchar(12);"
	$SQLITE3 $GEONAMESDB <<<"UPDATE geoname SET fclasscode = fclass || '.' || fcode;"
	#$SQLITE3 $GEONAMESDB <<<"SELECT AddGeometryColumn( 'geoname', 'the_geom', 4326, 'POINT', 2);"
	#$SQLITE3 $GEONAMESDB  <<<"UPDATE geoname SET the_geom = ST_PointFromText('POINT(' || longitude || ' ' || latitude || ')', 4326);"
	$SQLITE3 $GEONAMESDB <<<"CREATE INDEX geoname_fcode ON geoname(fcode);"
	$SQLITE3 $GEONAMESDB <<<"CREATE INDEX geoname_adminx ON geoname(admin1, admin2, admin3, admin4);"
	#$SQLITE3 $GEONAMESDB <<<"CREATE INDEX geoname_the_geom_gist_idx ON geoname using gist (the_geom);"
	$SQLITE3 $GEONAMESDB <<<"CREATE INDEX geoname_geonameid_idx ON geoname(geonameid);"
	$SQLITE3 $GEONAMESDB <<<"CREATE INDEX geoname_name_idx ON geoname(name);"
	$SQLITE3 $GEONAMESDB <<<"CREATE INDEX geoname_fclass_idx ON geoname(fclass);"
	$SQLITE3 $GEONAMESDB <<<"CREATE INDEX geoname_country_idx ON geoname(country);"

	# alternateNames table
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/alternateNamesV2.txt alternatename"
	$SQLITE3 $GEONAMESDB <<<"CREATE INDEX alternatename_geonameid_idx ON alternatename(geonameid);"

	# isolanguagecodes
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/iso-languagecodes.txt isolanguagecode"

	# countryinfo
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/countryInfo.txt countryinfo"

	# admin1codesascii
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/admin1CodesASCII.txt admin1codeascii"
	$SQLITE3 $GEONAMESDB <<<"create index admin1codesascii_geonameid_idx on admin1codesascii(geonameid);"

	# admin2codes
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/admin2Codes.txt admin2codes"
	$SQLITE3 $GEONAMESDB <<<"create index admin2codes_geonameid_idx on admin2codes(geonameid);"

	# featurecodes
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/featureCodes_bg.txt featurecodes"
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/featureCodes_en.txt featurecodes"
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/featureCodes_nb.txt featurecodes"
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/featureCodes_nn.txt featurecodes"
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/featureCodes_no.txt featurecodes"
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/featureCodes_ru.txt featurecodes"
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/featureCodes_sv.txt featurecodes"

	# usertags
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/userTags.txt usertags"
	$SQLITE3 $GEONAMESDB <<<"CREATE INDEX usertags_geonameid_idx ON usertags(geonameid);"
	#$SQLITE3 $GEONAMESDB <<<"ALTER TABLE usertags ADD FOREIGN KEY (geonameid) REFERENCES geoname(geonameid);"

	# hierarchy
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/hierarchy.txt hierarchy"
	$SQLITE3 $GEONAMESDB <<<"CREATE INDEX hierarchy_idx ON hierarchy(parentid, childid);"
	#$SQLITE3 $GEONAMESDB <<<"ALTER TABLE hierarchy ADD FOREIGN KEY (parentid) REFERENCES geoname(geonameid);"
	#$SQLITE3 $GEONAMESDB <<<"ALTER TABLE hierarchy ADD FOREIGN KEY (childid) REFERENCES geoname(geonameid);"

	# admincode5
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/adminCode5.txt admincode5"
	#$SQLITE3 $GEONAMESDB <<<"ALTER TABLE admincode5 ADD PRIMARY KEY (geonameid);"
	#$SQLITE3 $GEONAMESDB <<<"ALTER TABLE admincode5 ADD FOREIGN KEY (geonameid) REFERENCES geoname(geonameid);"

	# usertags
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/userTags.txt usertags"
	$SQLITE3 $GEONAMESDB <<<"CREATE INDEX usertags_idx ON usertags(geonameid);"
	#$SQLITE3 $GEONAMESDB <<<"ALTER TABLE usertags ADD FOREIGN KEY (parentid) REFERENCES geoname(geonameid);"

	# postalcodes
	$SQLITE3 $GEONAMESDB -cmd ".mode csv" -cmd ".separator \t" <<<".import $WORK_DIR/postalcodes-allCountries.txt postalcodes"
	$SQLITE3 $GEONAMESDB <<<"create index postalcodes_idx on postalcodes(postalcode, countrycode);"

	# continent
	$SQLITE3 $GEONAMESDB <<<"INSERT INTO continentinfo VALUES ('AF', 'Africa', 6255146);"
	$SQLITE3 $GEONAMESDB <<<"INSERT INTO continentinfo VALUES ('AS', 'Asia', 6255147);"
	$SQLITE3 $GEONAMESDB <<<"INSERT INTO continentinfo VALUES ('EU', 'Europe', 6255148);"
	$SQLITE3 $GEONAMESDB <<<"INSERT INTO continentinfo VALUES ('NA', 'North America', 6255149);"
	$SQLITE3 $GEONAMESDB <<<"INSERT INTO continentinfo VALUES ('OC', 'Oceania', 6255150);"
	$SQLITE3 $GEONAMESDB <<<"INSERT INTO continentinfo VALUES ('SA', 'South America', 6255151);"
	$SQLITE3 $GEONAMESDB <<<"INSERT INTO continentinfo VALUES ('AN', 'Antarctica', 6255152);"
	#$SQLITE3 $GEONAMESDB <<<"ALTER TABLE continentinfo ADD PRIMARY KEY (geonameid);"
	#$SQLITE3 $GEONAMESDB <<<"ALTER TABLE continentinfo ADD FOREIGN KEY (geonameid) REFERENCES geoname(geonameid);"

	# shapes
	$SQLITE3 $GEONAMESDB <<<"DROP TABLE IF EXISTS shapessimplifiedlow";
	#$OGR2OGR -f "PostgreSQL" PG:"dbname=$GEONAMESDB user=$DBUSER" $WORK_DIR/shapes_simplified_low.json -nln shapessimplifiedlow -overwrite
}

main $@
