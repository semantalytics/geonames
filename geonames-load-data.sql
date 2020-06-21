copy geoname (geonameid,name,asciiname,alternatenames,latitude,longitude,fclass,fcode,country,cc2,admin1,admin2,admin3,admin4,population,elevation,gtopo30,timezone,moddate) from '/tmp/geonames/geonames-allCountries.txt' with null as ''"

copy alternatename  (alternatenameid,geonameid,isoLanguage,alternateName,isPreferredName,isShortName,isColloquial,isHistoric, \"from\", \"to\") from '/tmp/geonames/alternateNamesV2.txt' null as ''"

copy countryinfo (isoalpha2,isoalpha3,isonumeric,fipscode,name,capital,areainsqkm,population,continent,tld,currencycode,currencyname,phone,postalcode,postalcoderegex,languages,geonameid,neighbours,equivalentfipscode) from '/tmp/geonames/countryInfo.txt' null as ''"

copy hierarchy (parentId,childId,type) from '/tmp/geonames/hierarchy.txt' null as ''"

copy admin2codes (admin2, name, asciiname, geonameid) from '/tmp/geonames/admin2Codes.txt' null as ''"

copy continentinfo (continent, geonameid) from '/tmp/geonames/geonames-continents.txt' null as ''"

copy iso_languagecodes from '/tmp/geonames/iso-languagecodes.txt' null '' delimiter E'\t' csv header;"

copy admin1codesascii (code,name,nameAscii,geonameid) from '/tmp/geonames/admin1CodesASCII.txt' null as '';"
 
copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_bg.txt' null as '';"
 
copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_en.txt' null as '';"
 
copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_nb.txt' null as '';"
 
copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_nn.txt' null as '';"
 
copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_no.txt' null as '';"
 
copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_ru.txt' null as '';"
 
copy featurecodes (code,ang,name,description) from '/tmp/geonames/featureCodes_sv.txt' null as '';"

copy timezones (countrycode, timezoneid, gmtoffset, dstoffset, rawoffset) from '/tmp/geonames/timeZones.txt' null '' delimiter E'\t' csv header;"
   
copy postalcodes (countrycode,postalcode,placename,admin1name,admin1code,admin2name,admin2code,admin3name, admin3code,latitude,longitude,accuracy) from '/tmp/geonames/postalcodes-allCountries.txt' null as '';"

copy admincode5 from '/tmp/geonames/adminCode5.txt' null as '';"

copy usertags from '/tmp/geonames/userTags.txt' null as '';"

copy shapessimilifiedlow(geonameid, geojson) from '/tmp/geonames/shapes_all_low.txt' null as 
