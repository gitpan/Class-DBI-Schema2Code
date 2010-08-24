#!/usr/bin/perl

use strict;
use warnings;

use Carp;
use DBI;
use DBIx::Table2Hash;
use FindBin;

# -----------------------------------------------

sub create_tables
{
	my($dbh) = @_;
	my(%sql) =
	(
		address => q
		{
			create table address
			(
				address_id integer auto_increment primary key,
				address_email varchar(255),
				address_fax varchar(255),
				address_line varchar(255),
				address_phone varchar(255)
			)
		},
		campus => q
		{
			create table campus
			(
				campus_id integer auto_increment primary key,
				campus_address_id integer,
				campus_campus_type_id integer,
				campus_code varchar(3),
				campus_home_page varchar(255),
				campus_is_visible varchar(3),
				campus_local_name varchar(255),
				campus_name varchar(255),
				campus_official_name varchar(255),
				campus_order_of_merit integer
			)
		},
		campus_type => q
		{
			create table campus_type
			(
				campus_type_id integer auto_increment primary key,
				campus_type_name varchar(255)
			)
		}
	);

	for (keys %sql)
	{
		$dbh -> do("drop table if exists $_");
		$dbh -> do($sql{$_});
	}

	populate_address_table($dbh);
	populate_campus_type_table($dbh);
	populate_campus_table($dbh);

}	# End of create_tables.

# -----------------------------------------------
# Populate table:
# o address

sub populate_address_table
{
	my($dbh)		= @_;
	my($sth)		= $dbh -> prepare("insert into address (address_line, address_phone, address_fax, address_email) values (?, ?, ?, ?)");
	my($file_name)	= "$FindBin::Bin/address.txt";

	open(INX, $file_name) || Carp::croak("Can't open($file_name): $!");
	my(@line) = <INX>;
	close INX;
	chomp(@line);

	my(@data, @address);

	for (@line)
	{
		next if (/^\s*$/ || /^\s*#/);

		@data = split(/,/, $_, -1);
		@data = map{$_ ? $_ : ''} @data;

		$address[0]	= join(',', grep{$_} @data[0 .. 7]);
		$address[1]	= join(',', grep{$_} @data[8 .. 9]);
		$address[2]	= join(',', grep{$_} @data[10 .. 11]);
		$address[3]	= join(',', grep{$_} @data[12 .. 13]);

		$sth -> execute(@address);
	}

	close INX;

	$sth -> finish();

}	# End of populate_address_table.

# -----------------------------------------------
# Populate table:
# o campus

sub populate_campus_table
{
	my($dbh)			= @_;
	my($address_id2id)	= DBIx::Table2Hash -> new
	(
		dbh				=> $dbh,
		table_name		=> 'address',
		key_column		=> 'address_id',
		value_column	=> 'address_id'
	) -> select();
	my($campus_type_name2id)	= DBIx::Table2Hash -> new
	(
		dbh				=> $dbh,
		table_name		=> 'campus_type',
		key_column		=> 'campus_type_name',
		value_column	=> 'campus_type_id'
	) -> select();

	my($sql)		= "insert into campus (campus_campus_type_id, campus_address_id, campus_is_visible, campus_order_of_merit, campus_official_name, campus_local_name, campus_name, campus_home_page, campus_code) values (?, ?, ?, ?, ?, ?, ?, ?, ?)";
	my($sth)		= $dbh -> prepare($sql);
	my($file_name)	= "$FindBin::Bin/campus.txt";

	open(INX, $file_name) || Carp::croak("Can't open($file_name): $!");
	my(@line) = <INX>;
	close INX;
	chomp(@line);

	my(@data);

	for (@line)
	{
		next if (/^\s*$/ || /^\s*#/);

		@data = split(/\t/, $_);

		Carp::croak("Campus: $data[4]. Invalid address id")		if (! $$address_id2id{$data[0]});
		Carp::croak("Campus: $data[4]. Invalid campus type")	if (! $$campus_type_name2id{$data[3]});

		$data[0] = $$address_id2id{$data[0]};
		$data[3] = $$campus_type_name2id{$data[3]};

		$sth -> execute($data[3], $data[0], $data[2], $data[1], $data[4], $data[5], $data[6], $data[7], $data[8]);
	}

	close INX;

	$sth -> finish();

}	# End of populate_campus_table.

# -----------------------------------------------
# Populate table:
# o campus_type

sub populate_campus_type_table
{
	my($dbh)		= @_;
	my($sql)		= "insert into campus_type (campus_type_name) values (?)";
	my($sth)		= $dbh -> prepare($sql);
	my($file_name)	= "$FindBin::Bin/campus-type.txt";

	open(INX, $file_name) || Carp::croak("Can't open($file_name): $!");
	my(@line) = <INX>;
	close INX;
	chomp(@line);

	my(@data);

	for (@line)
	{
		next if (/^\s*$/ || /^\s*#/);

		$sth -> execute($_);
	}

	close INX;

	$sth -> finish();

}	# End of populate_campus_type_table.

# -----------------------------------------------

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

create_tables($dbh);
