package HTML::Template::Compiled::Plugin::HTML_Tags;
# $Id: HTML_Tags.pm,v 1.9 2006/11/04 19:39:52 tinita Exp $
use strict;
use warnings;
use Carp qw(croak carp);
use HTML::Template::Compiled::Expression qw(:expressions);
use HTML::Template::Compiled;
HTML::Template::Compiled->register('HTML::Template::Compiled::Plugin::HTML_Tags');
our $VERSION = '0.02';

sub register {
    my ($class) = @_;
    my %plugs = (
        tagnames => {
            HTML::Template::Compiled::Token::OPENING_TAG() => {
                HTML_OPTION => [sub { exists $_[1]->{NAME} }, qw(NAME)],
                HTML_SELECT => [sub { exists $_[1]->{NAME} }, qw(NAME SELECT_ATTR)],
                HTML_TABLE  => [
                    sub { exists $_[1]->{NAME} },
                    qw(NAME TH_ATTR TD_ATTR TR_ATTR TABLE_ATTR HEADER)
                ],
            },
        },
        compile => {
            HTML_SELECT => {
                open => \&_html_select,
            },
            HTML_OPTION => {
                open => \&_html_option,
            },
            HTML_TABLE => {
                open => \&_html_table,
            },
        },
    );
    return \%plugs;
}

sub _html_table {
    my ($htc, $token, $args) = @_;
    my $OUT = $args->{out};
    my $attr = $token->get_attributes;
    my $varstr = $htc->get_compiler->parse_var($htc,
        var => $attr->{NAME},
        method_call => $htc->method_call,
        deref => $htc->deref,
        formatter_path => $htc->formatter_path,
    );
    my $header = $attr->{HEADER} || 0;
    my $tr_attr = $attr->{TR_ATTR} || '';
    my $td_attr = $attr->{TD_ATTR} || '';
    my $th_attr = $attr->{TH_ATTR} || '';
    my $table_attr = $attr->{TABLE_ATTR} || '';
    for ($tr_attr, $td_attr, $th_attr, $table_attr) {
        s/'/\\'/g;
    }
    my $expression = qq#my \@aoa = \@{ +$varstr };\n#;
    $expression .= <<"EOM";
    $OUT '<table $table_attr>'."\\n";
if ($header) \{
    my \$header = shift \@aoa;
    $OUT join "", '<tr $tr_attr>', (map {
        qq#<th #.'$th_attr'.qq#>\$_</th>#
    } \@\$header), '</tr>', "\\n";
\}
for (\@aoa) \{
    $OUT join "\\n", '<tr $tr_attr>', (map {
        qq#<td #.'$td_attr'.qq#>\$_</th>#
    } \@\$_), '</tr>', "\\n";
\}
$OUT '</table>'. "\\n";
EOM
    return $expression;
}

sub _html_select {
    my ($htc, $token, $args) = @_;
    my $OUT = $args->{out};
    my $attr = $token->get_attributes;
    my $varstr = $htc->get_compiler->parse_var($htc,
        var => $attr->{NAME},
        method_call => $htc->method_call,
        deref => $htc->deref,
        formatter_path => $htc->formatter_path,
    );
    my $select_attr = $attr->{SELECT_ATTR} || '';
    $select_attr =~ s/'/\\'/g;
    my $expression = qq#\{\nmy \$var = $varstr;\n#;
    $expression .= qq#my \$attr = '$select_attr';\n#;
    $expression .= <<'EOM';
    my $name = $var->{name};
    my $value = $var->{value};
    my @options = @{ $var->{options} };
    my $select = qq#<select name="$name" $attr>\n#;
    $select .= HTML::Template::Compiled::Plugin::HTML_Tags::_options($value, @options);
    $select .= qq#\n</select>\n#;
EOM
    $expression .= qq#$OUT \$select;\n\}#;
    return $expression;
}

sub _html_option {
    my ($htc, $token, $args) = @_;
    my $OUT = $args->{out};
    my $attr = $token->get_attributes;
    my $varstr = $htc->get_compiler->parse_var($htc,
        var => $attr->{NAME},
        method_call => $htc->method_call,
        deref => $htc->deref,
        formatter_path => $htc->formatter_path,
    );
    my $expression = qq#my \@aoa = \@{ +$varstr };\n#;
    $expression .= <<'EOM';
my $options = HTML::Template::Compiled::Plugin::HTML_Tags::_options(@aoa);
EOM
    $expression .= qq#$OUT \$options;\n#;
    return $expression;
}

sub _options {
    my @aoa = @_;
    my $selected = shift @aoa;
    my $options = join "\n", map {
        my $escaped = HTML::Template::Compiled::Utils::escape_html($_->[0]);
        my $sel = $_->[0] eq $selected ? 'selected="true"' : '';
        my $escaped_display = @$_ > 1
            ? HTML::Template::Compiled::Utils::escape_html($_->[1])
            : $escaped;
        qq#<option value="$escaped" $sel>$escaped_display</option>#;
    } @aoa;
}



1;

__END__

=pod

=head1 NAME

HTML::Template::Compiled::Plugin::HTML_Tags - HTC-Plugin for various HTML tags

=head1 SYNOPSIS

use HTML::Template::Compiled::Plugin::HTML_Tags;

    my $htc = HTML::Template::Compiled->new(
        plugin => [qw(HTML::Template::Compiled::Plugin::HTML_Tags)],
        ...
    );

=head1 DESCRIPTION

You have tnree tags with this plugin:

=over 4

=item HTML_OPTION

    <tmpl_html_option arrayref>

    $htc->param(
        arrayref => [ 'opt_2'
            ['opt_1', 'option 1'],
            ['opt_2', 'option 2'],
        ],
    );

    Output:
    <option value="opt_1">option 1</option>
    <option value="opt_2" selected="true">option 2</option>

=item HTML_SELECT

    <tmpl_html_select select SELECT_ATTR="class='myselect'">

    $htc->param(
        select => {
            name => 'foo',
            value => 'opt_1',
            options => [
                ['opt_1', 'option 1'],
                ['opt_2', 'option 2'],
            ],
        },
    );

    Output:
    <select name='foo' class='myselect'>
    <option value="opt_1" selected="true">option 1</option>
    <option value="opt_2">option 2</option>
    </select>

=item HTML_TABLE

    <tmpl_html_table arrayref
    header=1
    table_attr="bgcolor='black'"
    tr_attr="bgcolor='red'"
    th_attr="bgcolor='green'"
    td_attr="bgcolor='green'"

    $htc->param(
        arrayref => [
            [qw(foo bar)],
            [qw(foo bar)],
            [qw(foo bar)],
        ],
    );

    Output:
    <table bgcolor='black'>
    <tr bgcolor='red'>
    <th bgcolor='green'>foo</th><th bgcolor='green'>bar</th>
    </tr>
    <tr bgcolor='red'>
    <td bgcolor='green'>foo</td><td bgcolor='green'>bar</td>
    </tr>
    ...
    </table>

=back

=head1 EXAMPLES

See the examples directory in this distribution.

=head1 METHODS

=over 4

=item register

gets called by HTC

=back

=head1 AUTHOR

Tina Mueller

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Tina Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.


=cut

