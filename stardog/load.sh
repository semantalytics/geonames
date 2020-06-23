#!/bin/bash

wget -c -P ./downloads/ http://downloads.dbpedia.org/3.6/links/geonames_links.nt.bz2
wget -c -P ./downloads/ http://www.geonames.org/ontology/ontology_v3.2.rdf
wget -c -P ./downloads/ http://www.geonames.org/ontology/mappings_v3.01.rdf

stardog-admin db drop geonames

stardog-admin db create -n geonames --copy-server-side -o spatial.enabled=true search.enabled=true virtual.transparency=true -- downloads/geonames_links.nt.bz2 downloads/ontology_v3.2.rdf downloads/mappings_v3.01.rdf

stardog-admin virtual add --database geonames --overwrite geonames.properties geonames.sms2
