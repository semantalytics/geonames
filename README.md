# Geonames

## install postgres

```bash
sudo yum install postgres-server postgresql-contrib
sudo postgresql-setup initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

## install postgis

```bash
sudo yum -y install epel-release
sudo yum -y install postgis postgis-utils
initdb

createdb geonames
```

## Import Geonames into Postgres

```bash
./postgres/load.sh
```

## import data and virtual-graph into Stardog

```bash
./stardog/load.sh
```

## dump data

## SPARQL queries

## Convert Geonames RDF dump to nt

```bash
./rdf-dump/rdf-dump-to-nt.sh
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
- skip admin2 with 00??
