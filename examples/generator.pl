#!/usr/bin/perl
#
# Name:
#	generator.pl.
#
# Purpose:
#	Use Class::DBI::Schema2Code to generate a set of modules
#	matching a given database schema.

use strict;
use warnings;

use Class::DBI::Schema2Code;
use DBI;

# --------------------------

my($dbh) = DBI -> connect
(
	'dbi:mysql:test:127.0.0.1', 'root', 'pass',
	{
		AutoCommit         => 1,
		PrintError         => 0,
		RaiseError         => 1,
		ShowErrorStatement => 1,
	}
);

my($generator) = Class::DBI::Schema2Code -> new(base_name => 'Local::Project', dbh => $dbh);

$generator -> generate_parent_module('root', 'pass');

# Skip 'sessions' table used by CGI::Session,
# because it's column naming scheme does not
# match the convention I happen to use.

$generator -> generate_generic_module($_) for grep{! /^sessions$/} @{$generator -> tables()};
