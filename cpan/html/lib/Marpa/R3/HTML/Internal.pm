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

# DO NOT EDIT THIS FILE DIRECTLY
# It was generated by make_internal_pm.pl

package Marpa::R3::Internal;

use 5.010;
use strict;
use warnings;
use Carp;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '3.001_000';
$STRING_VERSION = $VERSION;
$VERSION = eval $VERSION;


package Marpa::R3::HTML::Internal::TDesc;
use constant TYPE => 0;
use constant START_TOKEN => 1;
use constant END_TOKEN => 2;
use constant VALUE => 3;
use constant RULE_ID => 4;

package Marpa::R3::HTML::Internal::Token;
use constant TOKEN_ID => 0;
use constant TAG_NAME => 0;
use constant TYPE => 1;
use constant LINE => 2;
use constant COL => 3;
use constant COLUMN => 3;
use constant START_OFFSET => 4;
use constant END_OFFSET => 5;
use constant IS_CDATA => 6;
use constant ATTR => 7;

1;