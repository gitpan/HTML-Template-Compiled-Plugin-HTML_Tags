# $Id: 01_HTML-Template-Compiled-Plugin-HTML_Tags.t,v 1.1 2006/11/03 20:54:00 tinita Exp $
use warnings;
use strict;
use blib;
use lib 't';
use Test::More tests => 2;
use_ok('HTML::Template::Compiled');
use_ok('HTML::Template::Compiled::Plugin::HTML_Tags');
exit;
{
    my $htc = HTML::Template::Compiled->new(
        plugin => ['HTML::Template::Compiled::Plugin::HTML_Tags'],
        scalarref => \<<'EOM',
<%HTML_OPTION foo%>
<%HTML_TABLE foo HEADER=1%>
EOM
        debug => 1,
    );
    $htc->param(
        foo => [
            3,
            [1, 'Jan'],
            [2, 'Feb'],
            [3, 'Mar'],
        ],
    );
    my $out = $htc->output;
    print "out: $out\n";
    cmp_ok($out, '=~', qr{<option.*1.*Jan.*<option.*2.*Feb.*<option.*Mar}s, "options");
}


