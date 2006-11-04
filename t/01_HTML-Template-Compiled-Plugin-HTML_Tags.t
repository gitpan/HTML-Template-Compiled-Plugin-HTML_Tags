# $Id: 01_HTML-Template-Compiled-Plugin-HTML_Tags.t,v 1.3 2006/11/04 19:40:29 tinita Exp $
use warnings;
use strict;
use blib;
use lib 't';
use Test::More tests => 5;
use_ok('HTML::Template::Compiled');
use_ok('HTML::Template::Compiled::Plugin::HTML_Tags');

my ($exp_2, $exp_3);
{
    local $/;
    my $exp = <DATA>;
    ($exp_2, $exp_3) = split /^-+$/m, $exp;
}

{
    my $htc = HTML::Template::Compiled->new(
        plugin => ['HTML::Template::Compiled::Plugin::HTML_Tags'],
        scalarref => \<<'EOM',
<%HTML_OPTION foo%>
EOM
        debug => 0,
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
    #print "out: $out\n";
    cmp_ok($out, '=~', qr{<option.*1.*Jan.*<option.*2.*Feb.*<option.*Mar}s, "options");
}
{
    my $htc = HTML::Template::Compiled->new(
        plugin => ['HTML::Template::Compiled::Plugin::HTML_Tags'],
        scalarref => \<<'EOM',
<%HTML_TABLE foo HEADER=1%>
EOM
        debug => 0,
    );
    $htc->param(
        foo => [
            [1, 'Jan'],
            [2, 'Feb'],
            [3, 'Mar'],
        ],
    );
    my $out = $htc->output;
    #print "out: $out\n";
    $exp_2 =~ s/\s+//g;
    $out =~ s/\s+//g;
    cmp_ok($out, 'eq', $exp_2, "table");
}
{
    my $htc = HTML::Template::Compiled->new(
        plugin => ['HTML::Template::Compiled::Plugin::HTML_Tags'],
        scalarref => \<<'EOM',
<%HTML_SELECT foo SELECT_ATTR="class='myselect'"%>
EOM
        debug => 0,
    );
    $htc->param(
        foo => {
            name    => 'foo',
            value   => 2,
            options => [
                [1, 'Jan'],
                [2, 'Feb'],
                [3, 'Mar'],
            ],
        },
    );
    my $out = $htc->output;
    #print "out: $out\n";
    $exp_3 =~ s/\s+//g;
    $out =~ s/\s+//g;
    cmp_ok($out, 'eq', $exp_3, "select");
}


__DATA__
<table >
<tr ><th >1</th><th >Jan</th></tr>
<tr >
<td >2</th>
<td >Feb</th>
</tr>

<tr >
<td >3</th>
<td >Mar</th>
</tr>

</table>
----------------------------
<select name="foo" class='myselect'>
<option value="1" >Jan</option>
<option value="2" selected="true">Feb</option>
<option value="3" >Mar</option>
</select>
