use Module::Build;

Module::Build -> new
(
	module_name		=> 'Class::DBI::Schema2Code',
	license			=> 'artistic',
	dist_author		=> 'Ron Savage <ron@savage.net.au>',
	build_requires	=>
	{
		Test::More	=> 0,
		Test::Pod	=> 0,
	},
	requires		=>
	{
		DBIx::Admin::TableInfo	=> 0,
		File::Path				=> 0,
		HTML::Template			=> 0,
	},
) -> create_build_script();