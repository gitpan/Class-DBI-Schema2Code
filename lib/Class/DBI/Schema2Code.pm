package Class::DBI::Schema2Code;

# Name:
#	Class::DBI::Schema2Code.
#
# Documentation:
#	POD-style documentation is at the end. Extract it with pod2html.*.
#
# Reference:
#	Object Oriented Perl
#	Damian Conway
#	Manning
#	1-884777-79-1
#	P 114
#
# Note:
#	o Tab = 4 spaces || die.
#
# Author:
#	Ron Savage <ron@savage.net.au>
#	Home page: http://savage.net.au/index.html
#
# Licence:
#	Australian copyright (c) 2004 Ron Savage.
#
#	All Programs of mine are 'OSI Certified Open Source Software';
#	you can redistribute them and/or modify them under the terms of
#	The Artistic License, a copy of which is available at:
#	http://www.opensource.org/licenses/index.html

use strict;
use warnings;
no warnings 'redefine';

require 5.005_62;

require Exporter;

use DBIx::Admin::TableInfo;
use File::Path;
use HTML::Template;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Class::DBI::Schema2Code ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);
our $VERSION = '1.05';

# -----------------------------------------------

# Preloaded methods go here.

# -----------------------------------------------

# Encapsulated class data.

{
	my(%_attr_data) =
	(	# Alphabetical order.
		_base_name		=> '',
		_dbh			=> '',
		_generic_module	=> 'generic-module.tmpl',
		_mkpath_mode	=> 0777,
		_module_path	=> '/perl/site/lib/',
		_parent_module	=> 'parent-module.tmpl',
		_template_path	=> '/apache2/htdocs/templates/schema2code',
	);

	sub _default_for
	{
		my($self, $attr_name) = @_;

		$_attr_data{$attr_name};
	}

	sub _init
	{
		my($self)				= @_;
		my($admin)				= DBIx::Admin::TableInfo -> new(dbh => $$self{'_dbh'});
		$$self{'_table'}		= $admin -> tables();
		$$self{'_table_name'}	= {};
		@{$$self{'_table_name'} }{@{$$self{'_table'} } } = (1) x @{$$self{'_table'} };
		$$self{'_column'}		= {};

		for my $table (@{$$self{'_table'} })
		{
			$$self{'_column'}{$table}	= $admin -> columns($table);
		}

	}	# End of _init.

	sub _standard_keys
	{
		keys %_attr_data;
	}

}	# End of encapsulated class data.

# -----------------------------------------------

sub generate_generic_module
{
	my($self, $table_name)	= @_;
	my($studly_caps)	= $self -> studly_caps($table_name);
	my($module_path)	= $$self{'_module_path'};
	$module_path		.= '/' if (substr($module_path, -1, 1) ne '/');
	$module_path		.= "$$self{'_base_name'}/$studly_caps";
	$module_path		=~ s|::|/|g;
	my(@module_name)	= split(/\//, $module_path);
	my($module_name)	= pop @module_name;
	$module_name		.= '.pm';
	$module_path		= join('/', @module_name) . '/';
	my($output_name)	= "$module_path$module_name";
	$$self{'_template'} = HTML::Template -> new(path => [$$self{'_template_path'}], filename => $$self{'_generic_module'});

	$$self{'_template'} -> param(base_name => $$self{'_base_name'});
	$$self{'_template'} -> param(module_name => $module_name);
	$$self{'_template'} -> param(module_path => $module_path);
	$$self{'_template'} -> param(studly_table_name => $studly_caps);
	$$self{'_template'} -> param(table_name => lc $table_name);

	my($table, $column, $column_name, @table);

	for $column (@{$$self{'_column'}{$table_name} })
	{
		$column_name = $column;
		$column_name = $1 if ($column_name =~ /^${table_name}_(.+)_id$/);

		push @table, {key_name => $column, base_name => $$self{'_base_name'}, relationship_name => $self -> studly_caps($column_name)} if ($column_name ne $column);
	}

	$$self{'_template'} -> param(has_a => \@table) if (@table);

	@table = ();

	for $table (@{$$self{'_table'} })
	{
		next if ($table =~ /^$table_name$/i);

		for $column (@{$$self{'_column'}{$table} })
		{
			push @table, {key_name => lc $table, base_name => $$self{'_base_name'}, relationship_name => $self -> studly_caps($table)} if ($column =~ /^${table}_${table_name}_id$/);
		}
	}

	$$self{'_template'} -> param(has_many => \@table) if (@table);

	mkpath([$module_path], 0, $$self{'_mkpath_mode'});

	open(OUT, "> $output_name") || Carp::croak("Can't open(> $output_name): $!");
	print OUT $$self{'_template'} -> output();
	close OUT;

}	# End of generate_generic_module.

# -----------------------------------------------

sub generate_parent_module
{
	my($self, $username, $password)	= @_;
	my($module_path)	= $$self{'_module_path'};
	$module_path		.= '/' if (substr($module_path, -1, 1) ne '/');
	$module_path		.= "$$self{'_base_name'}/";
	$module_path		=~ s|::|/|g;
	my(@module_name)	= split(/\//, $module_path);
	my($module_name)	= pop @module_name;
	$module_name		.= '.pm';
	$module_path		= join('/', @module_name) . '/';
	my($output_name)	= "$module_path$module_name";
	$$self{'_template'} = HTML::Template -> new(path => [$$self{'_template_path'}], filename => $$self{'_parent_module'});

	$$self{'_template'} -> param(base_name => $$self{'_base_name'});
	$$self{'_template'} -> param(module_name => $module_name);
	$$self{'_template'} -> param(module_path => $module_path);
	$$self{'_template'} -> param(username => $username);
	$$self{'_template'} -> param(password => $password);

	mkpath([$module_path], 0, $$self{'_mkpath_mode'});

	open(OUT, "> $output_name") || Carp::croak("Can't open(> $output_name): $!");
	print OUT $$self{'_template'} -> output();
	close OUT;

}	# End of generate_parent_module.

# -----------------------------------------------

sub new
{
	my($class, %arg)	= @_;
	my($self)			= bless({}, $class);

	for my $attr_name ($self -> _standard_keys() )
	{
		my($arg_name) = $attr_name =~ /^_(.*)/;

		if (exists($arg{$arg_name}) )
		{
			$$self{$attr_name} = $arg{$arg_name};
		}
		else
		{
			$$self{$attr_name} = $self -> _default_for($attr_name);
		}
	}

	Carp::croak(__PACKAGE__ . ". You must supply values for the 'base_name' and 'dbh' parameters") if (! ($$self{'_base_name'} && $$self{'_dbh'}) );

	$self -> _init();

	$self;

}	# End of new.

# -----------------------------------------------

sub studly_caps
{
	my($self, $s) = @_;

	$s = ucfirst $s;
	$s =~ s/(_)([a-z])/uc $2/eg;

	$s;

}	# End of studly_caps.

# -----------------------------------------------

sub tables
{
	my($self) = @_;

	$$self{'_table'}

}	# End of tables.

# -----------------------------------------------

1;

__END__

=head1 NAME

C<Class::DBI::Schema2Code> - Convert db schema to modules which use Class::DBI

=head1 Synopsis

=head1 Description

C<Class::DBI::Schema2Code> is a pure Perl module.

This module allows you to convert a database schema into the corresponding set of Perl
modules, all of which use Class::DBI.

One module is generated for each table in the schema.

This module uses HTML::Template, and templates compatible with that module, to generate
the code.

The demonstration program examples/generator.pl skips any table called 'sessions', since
CGI::Session uses a table of that name, and such a table does not use the same convention I
do to name columns.

The dmeonstration program examples/reporter.pl prints out all records in a sample database.

=head1 Distributions

This module is available both as a Unix-style distro (*.tgz) and an
ActiveState-style distro (*.ppd). The latter is shipped in a *.zip file.

See http://savage.net.au/Perl-modules.html for details.

See http://savage.net.au/Perl-modules/html/installing-a-module.html for
help on unpacking and installing each type of distro.

=head1 Which Database and What Defaults?

This article:

http://www.perl.com/pub/a/2003/07/15/nocode.html

says:

	Our base class inherits from Class::DBI::mysql instead of plain Class::DBI,
	so we can save ourselves the trouble of directly specifying the table
	columns for each of our database tables--the database-specific base
	classes will auto-create a set_up_table method to handle all this for you.

I did not test this feature, and do not use it, mainly because I have to ship and support
systems which run identically under MySQL and Postgres.

This latter constraint should explain the subs in parent-module.tmpl. Rather than
generating code based on a DSN containing 'mysql', and also generating code based on a DSN
containing 'Pg', I have included templates which have a C<sub get_driver()> in the parent
template, and which have C<__PACKAGE__ -> sequence(...)> code in the generic template.

Simply edit the templates to suit your environment.

=head1 Constructor and initialization

new(...) returns a C<Class::DBI::Schema2Code> object.

This is the class's contructor.

Usage: Class::DBI::Schema2Code -> new(base_name => 'Local::Project', dbh => $dbh).

C<new()> takes at least 2 parameters.

=over 4

=item base_name => 'Local::Project'

This is the base name of the classes which will be generated.

So, the template parent-module.tmpl will be used to generate Project.pm, and will write it
into /perl/site/lib/Local/Project.pm (by default).

Also, the template generic-module.tmpl will be used to generate X.pm for each table x, and
will write each such module into /perl/site/lib/Local/Project/X.pm.

See module_path, below, for how to influence the output path.

Tables with names like abc_xyz will be converted to modules with names in the studly caps
format: AbcXyz.pm.

The default for this parameter is '' (the empty string).

This parameter is mandatory.

=item dbh => $dbh

A database handle, used to call DBI's table_info via DBIx::Admin::TableInfo.

This provides the list of table names and column names per table, which are then used to
generate the code.

The default for this parameter is '' (the empty string).

This parameter is mandatory.

=item generic_module => 'generic-module.tmpl'

This is the name of the file containing the template for generic modules, which means those
modules generated at a rate of 1 per table.

The default for this parameter is 'generic-module.tmpl'.

This parameter is optional.

=item mkpath => <An octal number>

This is the permissions parameter passed as the 3rd parameter to mkpath, used when creating
(if necessary) the directory structure to write to.

The default for this parameter is 0777.

This parameter is optional.

=item module_path => '/perl/site/lib/'

This is the prefix of the path to which the generated modules will be written.

The default for this parameter is '/perl/site/lib/'.

This parameter is optional.

=item parent_module => 'parent-module.tmpl'

This is the name of the file containing the template for the parent module, from which
all the other modules will inherit.

The default for this parameter is 'parent-module.tmpl'.

This parameter is optional.

=item template_path => '/apache2/htdocs/templates/schema2code'

This is the path used by HTML::Template to find the 2 templates given by the values of
the parameters generic_module and parent_module.

The default for this parameter is '/apache2/htdocs/templates/schema2code'.

This parameter is optional.

=back

=head1 Method: generate_generic_module($table_name)

Takes 1 parameter, the name of a table.

This method uses the template 'generic-module.tmpl' (by default) to generate the Perl module
for the given table.

=head1 Method: generate_parent_module($username, $password)

Takes 2 parameters, a username and a password.

This method uses the template 'parent-module.tmpl' (by default) to generate the Perl module
from which all the other generated modules will inherit.

The username and password are injected into the output code in order to be passed to
C<Class::DBI::set_db()> for logging on to the database.

=head1 Method: studly_caps($s)

Takes 1 parameter, a string.

Returns a StudlyCaps version of the given string.

Eg: campus_type will be turned into CampusType.

Good for converting database table names into Perl module names.

=head1 Method: tables()

Takes no parameters.

Returns an array ref containing the names of the tables.

=head1 Example code

The directory examples/ contains sample code of various types:

=over 4

=item address.txt

Sample data read by bootstrap.pl.

=item campus.txt

Sample data read by bootstrap.pl.

=item campus_type.txt

Sample data read by bootstrap.pl.

=item bootstrap.pl

A program which creates a database containing 3 linked tables, and populates those tables.

Note: This program requires DBIx::Table2Hash.

=item generator.pl

A program which generates a set of classes for the sample database.

=item address-print.pl

A fragment of code for you to plug into the generated file Address.pm, to better exercise
reporter.pl. It replaces C<sub print()> in Address.pm.

=item campus-print.pl

A fragment of code for you to plug into the generated file Campus.pm, to better exercise
reporter.pl. It replaces C<sub print()> in Campus.pm.

=item reporter.pl

A program which tests some of the generated classes.

=item reporter.log

The output from a run of reporter.pl after those 2 C<sub print()>s were plugged into their
respective modules.

Your output should be identical, apart from OS-dependent line terminators.

=back

=head1 Resources

This article is still excellent, despite being slightly out-of-date:

http://www.perl.com/pub/a/2003/07/15/nocode.html

=head1 See Also

Since the generated code uses Class::DBI, you really should investigate that module.

The documentation for Class::DBI has a long section called 'See Also'.

To install Class::DBI you will need to have installed, in this order:

=over 4

=item Class::Accessor

=item Class::Data::Inheritable

=item IO::Scalar

=item Test::More

=item Class::Trigger

=item File::Temp

=item Class::WhiteHole

=item DBI

=item Ima::DBI

=item Scalar::List::Utils

Contains List::Util

=item Storable

=item UNIVERSAL::moniker

=back

Because of this complexity, you should install Class::DBI via the CPAN or CPANPLUS shell,
if at all possible.

=head1 Author

C<Class::DBI::Schema2Code> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2004.

Home page: http://savage.net.au/index.html

=head1 Copyright

Australian copyright (c) 2004, Ron Savage.
	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
