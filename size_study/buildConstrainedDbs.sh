#/bin/bash

sudo -u postgres psql postgres <<EOF

create database const_1000;
create database const_10000;
create database const_100000;
create database const_1000000;
create database const_10000000;

\connect const_1000
create table regions(loc varchar(25) primary key,
                     chrom varchar(7),
                     start int,
                     endpos int,
                     score1 real,
                     score2 int);
\copy regions from '/scratch/github/psql_study/data_1000' with delimiter E'\t';
create index regions_index on regions (loc, start, endpos);

\connect const_10000
create table regions(loc varchar(25) primary key,
                     chrom varchar(7),
                     start int,
                     endpos int,
                     score1 real,
                     score2 int);
\copy regions from '/scratch/github/psql_study/data_10000' with delimiter E'\t';
create index regions_index on regions (loc, start, endpos);

\connect const_100000
create table regions(loc varchar(25) primary key,
                     chrom varchar(7),
                     start int,
                     endpos int,
                     score1 real,
                     score2 int);
\copy regions from '/scratch/github/psql_study/data_100000' with delimiter E'\t';
create index regions_index on regions (loc, start, endpos);

\connect const_1000000
create table regions(loc varchar(25) primary key,
                     chrom varchar(7),
                     start int,
                     endpos int,
                     score1 real,
                     score2 int);
\copy regions from '/scratch/github/psql_study/data_1000000' with delimiter E'\t';
create index regions_index on regions (loc, start, endpos);

\connect const_10000000
create table regions(loc varchar(25) primary key,
                     chrom varchar(7),
                     start int,
                     endpos int,
                     score1 real,
                     score2 int);
\copy regions from '/scratch/github/psql_study/data_10000000' with delimiter E'\t';
create index regions_index on regions (loc, start, endpos);

EOF
