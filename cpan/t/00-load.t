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

use 5.010;
use warnings;
use strict;
use English qw( -no_match_vars );

use Test::More tests => 4;

if (not eval { require Marpa::R3; 1; }) {
    Test::More::diag($EVAL_ERROR);
    Test::More::BAIL_OUT('Could not load Marpa::R3');
}

my $marpa_version_ok = defined $Marpa::R3::VERSION;
my $marpa_version_desc =
    $marpa_version_ok
    ? 'Marpa::R3 version is ' . $Marpa::R3::VERSION
    : 'No Marpa::R3::VERSION';
Test::More::ok( $marpa_version_ok, $marpa_version_desc );

my $marpa_string_version_ok   = defined $Marpa::R3::STRING_VERSION;
my $marpa_string_version_desc = "Marpa::R3 version is " . $Marpa::R3::STRING_VERSION
    // 'No Marpa::R3::STRING_VERSION';
Test::More::ok( $marpa_string_version_ok, $marpa_string_version_desc );

my @libmarpa_version    = Marpa::R3::Thin::version();
my $libmarpa_version_ok = scalar @libmarpa_version;
my $libmarpa_version_desc =
    $libmarpa_version_ok
    ? ( "Libmarpa version is " . join q{.}, @libmarpa_version )
    : "No Libmarpa version";
Test::More::ok( $libmarpa_version_ok, $libmarpa_version_desc );

Test::More::diag($marpa_string_version_desc);
Test::More::diag($libmarpa_version_desc);
Test::More::diag('Libmarpa tag: ' . Marpa::R3::Thin::tag());

my $grammar;
my $eval_ok = eval { $grammar = Marpa::R3::Thin::G->new( { if => 1 } ); 1 };
Test::More::diag($EVAL_ERROR) if not $eval_ok;
Test::More::ok( ($eval_ok && $grammar), 'Thin grammar created' )
    or Test::More::BAIL_OUT('Could not create Marpa grammar');

# vim: expandtab shiftwidth=4:
