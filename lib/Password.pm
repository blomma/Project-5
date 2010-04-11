# File      : Password.pm
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

package Password;
use New;
@ISA = qw( New );

$Password::date = '$Date: 2000/04/09 03:13:50 $';
$Password::revision = '$Id: Password.pm,v 1.8 2000/04/09 03:13:50 child Exp $';
$Password::VERSION = '0.2';

use strict;

my @salt  = ("A".."Z","a".."z","0".."9","-",".");
my @chars = ("A".."K","M".."N","P".."Z","a".."k","m".."n","p".."z","2".."9");

sub CryptPass {
    my ($self,$cleartext) = @_;
    my $salt = $chars[rand @chars].$chars[rand @chars];
    my $pw = crypt($cleartext,$salt);
    $self->Debug("Crypted password to $pw") if defined $self->{_debug};
    return $pw;
}

sub CreatePass {
    my ($self) = @_;

    my $password;
    for ( my $i=1; $i<=8; $i++ ) {
        $password .= $chars[rand(@chars)];
    }
    $self->Debug("Created random pass $password") if defined $self->{_debug};
    return $password;
}

sub GetVersion { my $self = $_[0]; return $Password::VERSION }

1;
