#!/usr/bin/perl
#
# Name:
#	reporter.pl.
#
# Purpose:
#	Display some data using the modules generated by generator.pl.

use strict;
use warnings;

use Local::Project::Address;
use Local::Project::Campus;

# -----------------------------------------------

my($iterator, $campus, $address);

# Warning: Do not use:
# my($iterator) = Local::Project::Campus -> retrieve_all();
# since the my(...) creates a list context which
# changes the behaviour of sub retrieve_all()
# You can use:
# my $iterator = Local::Project::Campus -> retrieve_all();

$iterator = Local::Project::Campus -> retrieve_all();

while ($campus = $iterator -> next() )
{
	$campus -> print();
}

print '-' x 50, "\n";

$iterator = Local::Project::Address -> retrieve_all();

while ($address = $iterator -> next() )
{
	$address -> print();
}

print '-' x 50, "\n";