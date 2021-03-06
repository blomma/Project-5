# File      : Error.pm
# Author    : Mikael hultgren <micke@four04.com>
#
# Copyright 1999-2000 Mikael hultgren <mike@four04.com> four04.  All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

package Error;
use New;
@ISA = qw( New );

$Error::date = '$Date: 2000/04/09 03:13:50 $';
$Error::revision = '$Id: Error.pm,v 1.3 2000/04/09 03:13:50 child Exp $';
$Error::VERSION = '0.2';

use strict;

sub GetVersion { my $self = $_[0]; return $Error::VERSION }
sub GetError   { my $self = $_[0]; return $self->{_error}   }
sub SetError   { my $self = $_[0]; $self->{_error} .= $_[1] }

1;
