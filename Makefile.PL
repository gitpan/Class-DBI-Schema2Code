use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		'AUTHOR' => 'Ron Savage (ron@savage.net.au)',
		'ABSTRACT' => 'Convert db schema to modules which use Class::DBI',
    ) : (),
	clean				=>
	{
		FILES			=> 'blib/* Makefile MANIFEST Class-DBI-Schema2Code-*'
	},
	dist				=>
	{
		COMPRESS		=> 'gzip',
		SUFFIX			=> 'gz'
	},
	DISTNAME			=> 'Class-DBI-Schema2Code',
	NAME				=> 'Class::DBI::Schema2Code',
	PL_FILES			=> {},
	PREREQ_PM			=>
	{
		DBIx::Admin::TableInfo	=> 0,
		File::Path				=> 0,
		HTML::Template			=> 0,
		Test::More				=> 0,
		Test::Pod				=> 0,
	},
	VERSION_FROM		=> 'lib/Class/DBI/Schema2Code.pm',
);
