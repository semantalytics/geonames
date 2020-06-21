# Geonames

## install postgres

```bash
sudo yum install postgres-server postgresql-contrib
sudo postgresql-setup initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

(include reference howto?)

## install postgis

```bash
sudo yum -y install epel-release
sudo yum -y install postgis postgis-utils
```

(include reference howto?)

## install stardog

```bash
wget https://downloads.stardog.com/stardog/stardog-latest.zip
unzip stardog-latest.zip
cd stardog-*
./bin/stardog-admin server start
```

## Download geonames

```bash
mkdir /tmp/geonames
cd /tmp/geonames

wget -c http://download.geonames.org/export/dump/allCountries.zip -O geonames-allCountries.zip
wget -c http://download.geonames.org/export/dump/alternateNamesV2.zip
wget -c http://download.geonames.org/export/dump/countryInfo.txt
wget -c http://download.geonames.org/export/dump/admin1CodesASCII.txt
wget -c http://download.geonames.org/export/dump/admin2Codes.txt
wget -c http://download.geonames.org/export/dump/timeZones.txt
wget -c http://download.geonames.org/export/dump/userTags.zip
wget -c http://download.geonames.org/export/dump/hierarchy.zip
wget -c http://download.geonames.org/export/dump/adminCode5.zip
wget -c http://download.geonames.org/export/zip/allCountries.zip -O postalcodes-allCountries.zip
wget -c http://download.geonames.org/export/dump/featureCodes_en.txt
wget -c http://download.geonames.org/export/dump/featureCodes_bg.txt
wget -c http://download.geonames.org/export/dump/featureCodes_nb.txt
wget -c http://download.geonames.org/export/dump/featureCodes_nn.txt
wget -c http://download.geonames.org/export/dump/featureCodes_no.txt
wget -c http://download.geonames.org/export/dump/featureCodes_ru.txt
wget -c http://download.geonames.org/export/dump/featureCodes_sv.txt
wget -c http://download.geonames.org/export/dump/shapes_simplified_low.json.zip

unzip geonames-allCountries.zip && mv allCountries.txt geonames-allCountries.txt
unzip alternateNamesV2.zip
unzip hierarchy.zip
unzip adminCode5.zip
unzip postalcodes-allCountries.zip && mv allCountries.txt postalcodes-allCountries.txt
unzip userTags.zip
unzip shapes_simplified_low.json.zip

sed -i -e '/\s*#/d' /tmp/geonames/countryInfo.txt
sed -i -e 's/\\//' postalcodes-allCountries.txt

sed -i -e 's/\t/\ten\t/' /tmp/geonames/featureCodes_en.txt
sed -i -e 's/\t/\tbg\t/' /tmp/geonames/featureCodes_bg.txt
sed -i -e 's/\t/\tnb\t/' /tmp/geonames/featureCodes_nb.txt
sed -i -e 's/\t/\tnn\t/' /tmp/geonames/featureCodes_nn.txt
sed -i -e 's/\t/\tno\t/' /tmp/geonames/featureCodes_no.txt
sed -i -e 's/\t/\tru\t/' /tmp/geonames/featureCodes_ru.txt
sed -i -e 's/\t/\tsv\t/' /tmp/geonames/featureCodes_sv.txt

sed -i -e '1d' shapes_all_low.txt 
```

## create postgres database

```bash
createdb -U postgres geonames
```

## enable spatial extension

```bash
psql -U postgres -d geonames -c "CREATE EXTENSION postgis"
```

## create schema

```bash
psql -U postgres -d geonames -f ./geonames-schema.sql
```

## copy data

```bash
psql -U postgres -d geonames -c "copy geoname (geonameid,name,asciiname,alternatenames,latitude,longitude,fclass,fcode,country,cc2,admin1,admin2,admin3,admin4,population,elevation,gtopo30,timezone,moddate) from '/tmp/geonames/geonames-allCountries.txt' with null as ''"

psql -U postgres -d geonames -c "copy alternatename  (alternatenameid,geonameid,isoLanguage,alternateName,isPreferredName,isShortName,isColloquial,isHistoric, \"from\", \"to\") from '/tmp/geonames/alternateNamesV2.txt' null as ''"

psql -U postgres -d geonames -c "copy countryinfo (isoalpha2,isoalpha3,isonumeric,fipscode,name,capital,areainsqkm,population,continent,tld,currencycode,currencyname,phone,postalcode,postalcoderegex,languages,geonameid,neighbours,equivalentfipscode) from '/tmp/geonames/countryInfo.txt' null as ''"

psql -U postgres -d geonames -c "copy hierarchy (parentId,childId,type) from '/tmp/geonames/hierarchy.txt' null as ''"

psql -U postgres -d geonames -c "copy admin2codes (admin2, name, asciiname, geonameid) from '/tmp/geonames/admin2Codes.txt' null as ''"

psql -U postgres -d geonames -c "copy continentinfo (continent, geonameid) from '/tmp/geonames/geonames-continents.txt' null as ''"

psql -U postgres -d geonames -c "copy iso_languagecodes from '/tmp/geonames/iso-languagecodes.txt' null '' delimiter E'\t' csv header;"

psql -U postgres -d geonames -c "copy admin1codesascii (code,name,nameAscii,geonameid) from '/tmp/geonames/admin1CodesASCII.txt' null as '';"
 
psql -U postgres -d geonames -c "copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_bg.txt' null as '';"
 
psql -U postgres -d geonames -c "copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_en.txt' null as '';"
 
psql -U postgres -d geonames -c "copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_nb.txt' null as '';"
 
psql -U postgres -d geonames -c "copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_nn.txt' null as '';"
 
psql -U postgres -d geonames -c "copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_no.txt' null as '';"
 
psql -U postgres -d geonames -c "copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_ru.txt' null as '';"
 
psql -U postgres -d geonames -c "copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_sv.txt' null as '';"

psql -U postgres -d geonames -c "copy timezones (countrycode, timezoneid, gmtoffset, dstoffset, rawoffset) from '/tmp/geonames/timeZones.txt' null '' delimiter E'\t' csv header;"
   
psql -U postgres -d geonames -c "copy postalcodes (countrycode,postalcode,placename,admin1name,admin1code,admin2name,admin2code,admin3name, admin3code,latitude,longitude,accuracy) from '/tmp/geonames/postalcodes-allCountries.txt' null as '';"

psql -U postgres -d geonames -c "copy admincode5 from '/tmp/geonames/adminCode5.txt' null as '';"

psql -U postgres -d geonames -c "copy usertags from '/tmp/geonames/userTags.txt' null as '';"

psql -U postgres -d geonames -c "copy shapessimilifiedlow(geonameid, geojson) from '/tmp/geonames/shapes_all_low.txt' null as '';"

ogr2ogr -f "PostgreSQL" PG:"dbname=geonames user=postgres" /tmp/geonames/shapes_simplified_low.json -nln shapessimplifiedlow
```

## create indexes and constraints

```sql
# Geoname table
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "alter table geoname add column fclasscode varchar(12);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "SELECT AddGeometryColumn( 'geoname', 'the_geom', 4326, 'POINT', 2);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "UPDATE geoname set fclasscode = concat(fclass, '.', fcode);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "update geoname SET the_geom = ST_PointFromText('POINT(' || longitude || ' ' || latitude || ')', 4326);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "create index geoname_the_geom_gist_idx on geoname using gist (the_geom);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "create index geoname_geonameid_idx on geoname(geonameid);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "create index geoname_name_idx on geoname(name);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "create index geoname_fclass_idx on geoname(fclass);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze geoname;"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "cluster geoname using geoname_the_geom_gist_idx;"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "analyze geoname;"

# alternateNames table
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "create index alternatename_alternatenameid_idx on alternatename(alternatenameid);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "create index alternatename_geonameid_idx on alternatename(geonameid);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze alternatename;"

# isolanguagecodes
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze isolanguage;"

# countryinfo
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "create index countryinfo_geonameid_idx on countryinfo(geonameid);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze countryinfo;"

# timezones
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "create index timezones_countrycode_idx on timezones(countrycode);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze timezones;"

# admin1codesascii
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "create index admin1codesascii_geonameid_idx on admin1codesascii(geonameid);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze admin1codesascii;"

# admin2codes
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "create index admin2codes_geonameid_idx on admin2codes(geonameid);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze admin2codes;"

# featurecodes
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "create index featurecodes_code_idx on featurecodes(code);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze featurecodes;"

# usertags
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "create index usertags_geonameid_idx on usertags(geonameid);"
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze usertags;"

# hierarchy

# admincode5
$PSQL --host=$DBHOST --port=$DBPORT  --username=$DBUSER --dbname=$GEONAMESDB -c "create index admincode5_geonameid_idx on admincode5(geonameid);"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$GEONAMESDB -c "vacuum analyze admincode5;"













ALTER TABLE ONLY alternatename
      ADD CONSTRAINT pk_alternatenameid PRIMARY KEY (alternatenameid);
ALTER TABLE ONLY geoname
      ADD CONSTRAINT pk_geonameid PRIMARY KEY (geonameid);
ALTER TABLE ONLY countryinfo
      ADD CONSTRAINT pk_iso_alpha2 PRIMARY KEY (iso_alpha2);

ALTER TABLE ONLY countryinfo
      ADD CONSTRAINT fk_geonameid FOREIGN KEY (geonameid) REFERENCES geoname(geonameid);
ALTER TABLE ONLY alternatename
      ADD CONSTRAINT fk_geonameid FOREIGN KEY (geonameid) REFERENCES geoname(geonameid);

```

## create geom

```sql
SELECT AddGeometryColumn ('public','geoname','the_geom',4326,'POINT',2);
UPDATE geoname SET the_geom = ST_PointFromText('POINT(' || longitude || ' ' || latitude || ')', 4326);
CREATE INDEX idx_geoname_the_geom ON public.geoname USING gist(the_geom);

SELECT AddGeometryColumn ('public','postalcodes','the_geom',4326,'POINT',2);
UPDATE postalcodes SET the_geom = ST_PointFromText('POINT(' || longitude || ' ' || latitude || ')', 4326);
CREATE INDEX idx_postalcodes_the_geom ON public.postalcodes USING gist(the_geom);


```

## create stardog mapping

## import into Stardog

## dump data

## SPARQL queries

##

Loading the geonames rdf dump

```bash
#!/bin/bash

while read file; do

   rapper --quiet <(echo $file) 2> errors
done < <(awk ‘NR % 2 == 0 { print; }’ $*)
```

## Next steps

## Notes
- https://github.com/briangmaddox/misc_gis_scripts/tree/master/geonames
- http://forum.geonames.org/gforum/posts/list/926.page
- https://www.logilab.org/10074668
- https://github.com/jvarga/geonames-for-postgis/blob/master/build_geonames.sh
- https://github.com/mattecasu/geonames-rdf
- https://github.com/hibernator11/geonames
- https://github.com/dbpedia/links

## todo
- docker compose setup
- add not null constraints
- map country as top level admin
- skip admin with 00
