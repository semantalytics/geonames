#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir $DIR/downloads

wget -c -P $DIR/downloads/ http://downloads.dbpedia.org/3.6/links/geonames_links.nt.bz2
wget -c -P $DIR/downloads/ http://www.geonames.org/ontology/ontology_v3.2.rdf
wget -c -P $DIR/downloads/ http://www.geonames.org/ontology/mappings_v3.01.rdf

stardog-admin db drop geonames

stardog-admin db create -n geonames --copy-server-side -o spatial.enabled=true search.enabled=true virtual.transparency=true query.all.graphs=true -- $DIR/downloads/geonames_links.nt.bz2 $DIR/downloads/ontology_v3.2.rdf $DIR/downloads/mappings_v3.01.rdf

stardog-admin virtual add --database geonames --overwrite geonames.properties geonames.sms2
