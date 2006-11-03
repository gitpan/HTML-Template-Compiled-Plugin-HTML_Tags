use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'traditional',
    license            => 'perl',
    module_name        => 'HTML::Template::Compiled::Plugin::HTML_Tags',
    requires => {
        'HTML::Template::Compiled' => '0.81',
    },
    recommends => {
    },
    create_readme      => 0,
    sign               => 0,
);
$build->create_build_script;
