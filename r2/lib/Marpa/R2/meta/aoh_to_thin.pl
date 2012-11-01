#!/usr/bin/perl
# Copyright 2012 Jeffrey Kegler
# This file is part of Marpa::R2.  Marpa::R2 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R2 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R2.  If not, see
# http://www.gnu.org/licenses/.

use 5.010;
use strict;
use warnings;
use English qw( -no_match_vars );
use Data::Dumper;

# This is a 'meta' tool, so I relax some of the
# restrictions I use to guarantee portability.
use Perl::Tidy;
use autodie;

# Appropriate PERLLIB settings are expected to
# be external
use Marpa::R2;

use Getopt::Long;
my $verbose   = 1;
my $help_flag = 0;
my $result    = Getopt::Long::GetOptions( 'help' => \$help_flag );
die "usage $PROGRAM_NAME [--help] file ...\n" if $help_flag;

my $aoh_source = join q{}, <>;
my $aoh;
unless ( $aoh = eval "no strict; $aoh_source" ) {
    die "couldn't parse $aoh_source: $EVAL_ERROR"
        if $EVAL_ERROR;
    die "couldn't do $aoh_source: $ERRNO"
        unless defined $aoh;
    die "couldn't run $aoh_source" unless $aoh;
} ## end unless ( my $aoh = do $aoh_source )

sub quote { return q{"} . (quotemeta shift) . q{"}; }

my %numeric = map {$_ => 1} qw(min proper);
my $untidied = '';
DESCRIPTOR: for my $descriptor ( @{$aoh} ) {
    my $min    = $descriptor->{min};
    my $method = defined $min ? 'sequence_new' : 'rule_new';
    my $lhs    = $descriptor->{lhs};
    my $rhs    = $descriptor->{rhs};
    $untidied .= '$tracer->' . $method . '( ';
    my $action = $descriptor->{action};
    $untidied .= defined $action ? quote($action) . q{=>} : 'undef,';
    $untidied .= join q{, }, map { quote($_) } ( $lhs, @{$rhs} );

    if ( defined $min ) {
        delete @{$descriptor}{qw(lhs rhs action)};
        $untidied .= q{, } . '{';
        for my $key ( keys %{$descriptor} ) {
            my $value = $descriptor->{$key};
            $value = quote($value) if not $numeric{$key};
            $untidied .= "$key=>$value,";
        }
        $untidied .= '}';
    } ## end if ( defined $min )
    $untidied .= q{ );} . "\n";
} ## end DESCRIPTOR: for my $descriptor ( @{$aoh} )

my $tidied;
Perl::Tidy::perltidy( argv => '-npro -nst', source => \$untidied, destination => \$tidied );
say "## The code after this line was automatically generated by ", $PROGRAM_NAME;
say "## Date: ", scalar localtime();
print $tidied;
say "## The code before this line was automatically generated by ", $PROGRAM_NAME;
