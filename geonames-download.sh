#!/bin/env bash


mkdir /tmp/geonames
cd /tmp/geonames

wget -c http://download.geonames.org/export/dump/allCountries.zip -O geonames-allCountries.zip
wget -c http://download.geonames.org/export/dump/alternateNamesV2.zip
wget -c http://download.geonames.org/export/dump/countryInfo.txt
wget -c http://download.geonames.org/export/dump/admin1CodesASCII.txt
wget -c http://download.geonames.org/export/dump/admin2Codes.txt
wget -c http://download.geonames.org/export/dump/featureCodes.txt
wget -c http://download.geonames.org/export/dump/timeZones.txt
wget -c http://download.geonames.org/export/dump/countryInfo.txt
wget -c http://download.geonames.org/export/dump/userTags.zip
wget -c http://download.geonames.org/export/dump/hierarchy.zip
wget -c http://download.geonames.org/export/dump/adminCode5.zip
wget -c http://download.geonames.org/export/zip/allCountries.zip -O postalcodes-allCountries.zip

unzip geonames-allCountries.zip && mv allCountries.txt geonames-allCountries.txt
unzip alternateNamesV2.zip
unzip hierarchy.zip
unzip adminCode5.zip
unzip postalcodes-allCountries.zip && mv allCountries.txt postalcodes-allCountries.txt
