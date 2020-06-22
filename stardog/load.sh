#!/bin/bash

wget -c http://downloads.dbpedia.org/3.6/links/geonames_links.nt.bz2
wget -c http://www.geonames.org/ontology/ontology_v3.2.rdf
wget -c http://www.geonames.org/ontology/mappings_v3.01.rdf

stardog-admin db drop geonames

stardog-admin db create -o spatial.enabled=true search.enabled=true -n geonaems geonames_links.nt.bz2 ontology_v3.2.rdf mappings_v3.01.rdf

stardog-admin virtual add --overwrite geonames.properties geonames.sms2
