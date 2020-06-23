#!/bin/bash

if [ $# == 0 ]; then 
	mkdir downloads
	wget -c -P downloads http://download.geonames.org/all-geonames-rdf.zip
	$1 = downloads/all-geonames-rdf.zip
fi

while read file; do
   rapper --quiet <(echo $file) 2> errors
done < <(awk 'NR % 2 == 0 { print; }' $*)
