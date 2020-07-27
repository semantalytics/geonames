DROP TABLE IF EXISTS geoname ;

CREATE TABLE geoname (
	geonameid INTEGER PRIMARY KEY,
	name VARCHAR(200),
	asciiname VARCHAR(200),
	alternatenames VARCHAR(10000),
	latitude FLOAT,
	longitude FLOAT,
	fclass CHAR(1),
	fcode VARCHAR(10),
	country VARCHAR(2),
	cc2 VARCHAR(200),
	admin1 VARCHAR(20),
	admin2 VARCHAR(80),
	admin3 VARCHAR(20),
	admin4 VARCHAR(20),
	population BIGINT,
	elevation INTEGER,
	dem INTEGER,
	timezone VARCHAR(40),
	moddate DATE
);

DROP TABLE IF EXISTS alternatename ;

CREATE TABLE alternatename (
	alternatenameId INTEGER PRIMARY KEY,
	geonameid INTEGER NOT NULL,
	isoLanguage VARCHAR(7),
	alternateName VARCHAR(200) NOT NULL,
	isPreferredName BOOLEAN,
	isShortName BOOLEAN,
	isColloquial BOOLEAN,
	isHistoric BOOLEAN,
	"from" VARCHAR,
	"to" VARCHAR,
	FOREIGN KEY geonameid REFERENCES geoname(geonameid)
);

DROP TABLE IF EXISTS countryinfo ;

CREATE TABLE countryinfo (
	isoalpha2 CHAR(2),
	isoalpha3 CHAR(3),
	isonumeric INTEGER,
	fipscode VARCHAR(3),
	name VARCHAR(200),
	capital VARCHAR(200),
	areainsqkm DOUBLE PRECISION,
	population INTEGER,
	continent CHAR(2),
	tld VARCHAR(10),
	currencycode VARCHAR(3),
	currencyname VARCHAR(40),
	phone VARCHAR(20),
	postalcode VARCHAR(100),
	postalcoderegex VARCHAR(200),
	languages VARCHAR(200),
	geonameId INTEGER,
	neighbours VARCHAR(60),
	equivalentfipscode VARCHAR(3)
);

DROP TABLE IF EXISTS admin1codesascii ;

CREATE TABLE "admin1codesascii" (
 	code CHAR(20),
 	name TEXT,
 	nameAscii TEXT,
 	geonameid INTEGER,
	FOREIGN KEY geonameid REFERENCES geoname(geonameid)
);

DROP TABLE IF EXISTS admin2codes ;

CREATE TABLE "admin2codes" (
	admin2 VARCHAR(80),
	name VARCHAR(200),
	asciiname VARCHAR(200),
	geonameid INT,
	FOREIGN KEY geonameid REFERENCES geoname(geonameid)
);

DROP TABLE IF EXISTS continentinfo ;

CREATE TABLE "continentinfo" (
 	code CHAR(2),
 	name VARCHAR(20),
 	geonameid INT,
	FOREIGN KEY geonameid REFERENCES geoname(geonameid)
);

DROP TABLE IF EXISTS "isolanguagecode" ;

CREATE TABLE "isolanguagecode" (
	iso_639_3 CHAR(4),
	iso_639_2 VARCHAR(50),
	iso_639_1 VARCHAR(50),
	language_name VARCHAR(200)
);

DROP TABLE IF EXISTS "featurecodes" ;

CREATE TABLE "featurecodes" (
 	code CHAR(7),
	lang CHAR(2),
 	name VARCHAR(200),
 	description TEXT
);

DROP TABLE IF EXISTS "timezones" ;

CREATE TABLE "timezones" (
	countrycode CHAR(2),
	timezoneid VARCHAR(200),
 	gmtoffset DOUBLE PRECISION,
 	dstoffset DOUBLE PRECISION,
	rawoffset DOUBLE PRECISION
);

DROP TABLE IF EXISTS "usertags" ;

CREATE TABLE "usertags" (
	geonameid BIGINT,
	tag VARCHAR(40),
	FOREIGN KEY geonameid REFERENCES geoname(geonameid)
);

DROP TABLE IF EXISTS "hierarchy" ;

CREATE TABLE "hierarchy" (
	parentid BIGINT NOT NULL,
	childid BIGINT NOT NULL,
	type VARCHAR(40),
	FOREIGN KEY parentid REFERENCES geoname(geonameid)
	FOREIGN KEY childid REFERENCES geoname(geonameid)
);

DROP TABLE IF EXISTS "admincode5" ;

CREATE TABLE "admincode5" (
	geonameid BIGINT,
	admcode5 TEXT
);

DROP TABLE IF EXISTS "postalcodes" ;

CREATE TABLE "postalcodes" (
 	countrycode CHAR(2),
 	postalcode VARCHAR(20),
 	placename VARCHAR(180),
 	admin1name VARCHAR(100),
 	admin1code VARCHAR(20),
 	admin2name VARCHAR(100),
 	admin2code VARCHAR(20),
 	admin3name VARCHAR(100),
 	admin3code VARCHAR(20),
 	latitude FLOAT,
 	longitude FLOAT,
 	accuracy SMALLINT
);
