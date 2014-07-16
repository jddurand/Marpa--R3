#!perl
# Copyright 2014 Jeffrey Kegler
# This file is part of Marpa::R3.  Marpa::R3 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R3.  If not, see
# http://www.gnu.org/licenses/.

# the example grammar in Aycock/Horspool "Practical Earley Parsing",
# _The Computer Journal_, Vol. 45, No. 6, pp. 620-630,
# in its "NNF" form

use 5.010;
use strict;
use warnings;

use Test::More tests => 26;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub default_action {
    shift;
    my $v_count = scalar @_;
    return q{}   if $v_count <= 0;
    return $_[0] if $v_count == 1;
    return '(' . ( join q{;}, @_ ) . ')';
} ## end sub default_action

## use critic

my $dsl = <<'END_OF_DSL';
:default ::= action => main::default_action
:start ::= S
S ::= A A A A
A ::=
A ::= 'a'
END_OF_DSL

my $slg = Marpa::R3::Scanless::G->new( {   source => \$dsl });
my $slr = Marpa::R3::Scanless::R->new( {   grammar => $slg });
my $input_length = 4;
my $input = ('a' x $input_length);
$slr->read( \$input );

my @expected = map {
    +{ map { ( $_ => 1 ) } @{$_} }
    }
    [q{}],
    [qw( (a;;;) (;a;;) (;;a;) (;;;a) )],
    [qw( (a;a;;) (a;;a;) (a;;;a) (;a;a;) (;a;;a) (;;a;a) )],
    [qw( (a;a;a;) (a;a;;a) (a;;a;a) (;a;a;a) )],
    ['(a;a;a;a)'];

$slr->set( { max_parses => 20 } );

my @ambiguity_expected;
$ambiguity_expected[0] = 'No ambiguity';

$ambiguity_expected[1] = <<'END_OF_AMBIGUITY_DESC';
Length of symbol "A" at line 1, column 1 is ambiguous
  Choice 1, length=1, ends at line 1, column 1
  Choice 1: a
  Choice 2 is zero length
END_OF_AMBIGUITY_DESC

$ambiguity_expected[2] = <<'END_OF_AMBIGUITY_DESC';
Length of symbol "A" at line 1, column 1 is ambiguous
  Choice 1 is zero length
  Choice 2, length=1, ends at line 1, column 1
  Choice 2: a
END_OF_AMBIGUITY_DESC

$ambiguity_expected[3] = <<'END_OF_AMBIGUITY_DESC';
Length of symbol "A" at line 1, column 1 is ambiguous
  Choice 1 is zero length
  Choice 2, length=1, ends at line 1, column 1
  Choice 2: a
Length of symbol "A" at line 1, column 2 is ambiguous
  Choice 1, length=1, ends at line 1, column 2
  Choice 1: a
  Choice 2 is zero length
END_OF_AMBIGUITY_DESC

$ambiguity_expected[4] = 'No ambiguity';

for my $i ( 0 .. $input_length ) {

    $slr->series_restart( { end => $i } );
    my $expected = $expected[$i];

# Marpa::R3::Display
# name: Scanless ambiguity_metric() synopsis

    my $ambiguity_metric = $slr->ambiguity_metric();

# Marpa::R3::Display::End

    $ambiguity_metric = 2 if $ambiguity_metric > 2; # cap at 2 -- higher numbers not defined
    my $expected_metric = (scalar keys %{$expected} > 1 ? 2 : 1);
    Test::More::is($ambiguity_metric, $expected_metric, "Ambiguity check for length $i");

    while ( my $value_ref = $slr->value() ) {

        my $value = $value_ref ? ${$value_ref} : 'No parse';
        if ( defined $expected->{$value} ) {
            delete $expected->{$value};
            Test::More::pass(qq{Expected result for length=$i, "$value"});
        }
        else {
            Test::More::fail(qq{Unexpected result for length=$i, "$value"});
        }
    } ## end while ( my $value_ref = $slr->value() )

    for my $value ( keys %{$expected} ) {
        Test::More::fail(qq{Missing result for length=$i, "$value"});
    }

    my $ambiguity_desc = 'No ambiguity';
    if ($ambiguity_metric > 1) {

        $slr->series_restart( { end => $i } );
        my $asf = Marpa::R3::ASF->new( { slr => $slr } );
        die 'No ASF' if not defined $asf;
        my $ambiguities = Marpa::R3::Internal::ASF::ambiguities($asf);

        # Only report the first two
        my @ambiguities = grep {defined} @{$ambiguities}[ 0 .. 1 ];

        $ambiguity_desc =
            Marpa::R3::Internal::ASF::ambiguities_show( $asf, \@ambiguities );
    }

    Marpa::R3::Test::is($ambiguity_desc, $ambiguity_expected[$i], "Ambiguity description for length $i");

} ## end for my $i ( 0 .. $input_length )

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
