# File      : Os.pm
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

package Os;
use New;
@ISA = qw( New );

$Os::date = '$Date: 2000/04/09 03:13:50 $';
$Os::revision = '$Id: Os.pm,v 1.8 2000/04/09 03:13:50 child Exp $';
$Os::VERSION = '0.2';

use strict;

sub CreateUser {
    my ($self,$accountUserName,$accountPassword) = @_;

    my @args = ("/usr/sbin/adduser","-c 'A test for the script'","-p$accountPassword","$accountUserName");

    system(@args) == 0
      or return("system @args failed: $?");
}

sub GetVersion { my $self = $_[0]; return $Os::VERSION }

1;
