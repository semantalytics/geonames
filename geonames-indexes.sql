ALTER TABLE alternatename ADD CONSTRAINT alternatename_pk PRIMARY KEY(alternatenameid);
ALTER TABLE geoname ADD CONSTRAINT geoname_pk PRIMARY KEY(geonameid);
create index geonamecountryindex on geoname (country);
create index countryindex on countryinfo (iso_alpha2);
create index hpindex on hierarchy (parentid);
create index hcindex on hierarchy (childid);
create index a1index on admin1codes (admin1);
create index a2index on admin2codes (admin2);
create index geonamename on geoname (name);
