#!/usr/bin/perl
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

# Tests requiring a grammar, an input and the expected events --
# no semantics required and output is not tested.

use 5.010;
use strict;
use warnings;
use English qw( -no_match_vars );
use Test::More tests => 2;

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R3;

my $DEBUG = 0;
my @tests_data = ();

# Location 0 events
# Bug found by Jean-Damien Durand

my $loc0_dsl = <<GRAMMAR_SOURCE;
:start ::= Script
Script ::= null1 null2 digits1 null3 null4 digits2 null5
digits1 ::= DIGITS
digits2 ::= DIGITS
null1   ::=
null2   ::=
null3   ::=
null4   ::=
null5   ::=
DIGITS ~ [\\d]+
WS ~ [\\s]
:discard ~ WS
GRAMMAR_SOURCE

foreach (
    qw/Script/,
    ( map {"digits$_"} ( 1 .. 2 ) ),
    ( map {"null$_"}   ( 1 .. 5 ) )
    )
{
    $loc0_dsl .= <<EVENTS;
event '${_}\$' = completed <$_>
event '^${_}' = predicted <$_>
event '${_}[]' = nulled <$_>
EVENTS
} ## end foreach ( qw/Script/, ( map {"digits$_"} ( 1 .. 2 ) ), ( ...))

my $loc0_input = '    1 2';
my $loc0_grammar = Marpa::R3::Scanless::G->new( { source  => \$loc0_dsl } );
my $loc0_events = <<'END_OF_EXPECTED_EVENTS';
^Script ^digits1 null1[] null2[]
^digits2 digits1$ null3[] null4[]
Script$ digits2$ null5[]
END_OF_EXPECTED_EVENTS

push @tests_data, [ $loc0_grammar, $loc0_input, $loc0_events, 'Location 0 events' ];

my $reject_dup_dsl = <<'END_OF_DSL';
:start ::= Script

Script ::= 'x' DUP 'y'

_S      ~ [\s]
_S_MANY ~ _S+
_S_ANY  ~ _S*
:lexeme ~ <DUP> pause => after event => 'DUP$'
DUP  ~ _S_ANY _S
     | _S _S_ANY

:discard ~ _S_MANY
END_OF_DSL
my $reject_dup_grammar = Marpa::R3::Scanless::G->new( { source  => \$reject_dup_dsl } );
my $reject_dup_input = " x y\n\n";
my $reject_dup_events = join "\n", 'DUP$', q{}, q{};
push @tests_data, [ $reject_dup_grammar, $reject_dup_input, $reject_dup_events, 'Events for rejected duplicates' ];

TEST:
for my $test_data (@tests_data) {
    my ( $grammar, $test_string, $expected_events, $test_name ) =
        @{$test_data};
    my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

    my $pos           = -1;
    my $length        = length $test_string;
    my $actual_events = q{};
    for ( my $pass = 0; $pos < $length; $pass++ ) {
        my $eval_ok;
        if ($pass) {
            $eval_ok = eval { $pos = $recce->resume(); 1 };
        }
        else {
            $eval_ok = eval { $pos = $recce->read( \$test_string ); 1 };
        }
        die $EVAL_ERROR if not $eval_ok;
        $actual_events .= record_events($recce);
    } ## end for ( my $pass = 0; $pos < $length; $pass++ )

    Test::More::is( $actual_events, $expected_events, $test_name );
} ## end for my $test_data (@tests_data)

sub record_events {
    my ( $recce, $pos ) = @_;
    my $text = q{};
    my @events;
    for (
        my $event_ix = 0;
        my $event    = $recce->event($event_ix);
        $event_ix++
        )
    {
        my ( $event_name, @event_data ) = @{$event};
        push @events, $event_name;
    } ## end for ( my $event_ix = 0; my $event = $recce->event($event_ix...))
    return ( join q{ }, sort @events ) . "\n";
} ## end sub record_events

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
