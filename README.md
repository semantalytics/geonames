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

## Import Geonames into Postgres

```bash
cd postgres
./load.sh

## import data and virtual-graph into Stardog

```bash
cd ../stardog
./load.sh
```

## dump data

## SPARQL queries

## Convert Geonames RDF dump to nt

```bash
cd ../rdf-dump
./rdf-dump-to-nt.sh
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
