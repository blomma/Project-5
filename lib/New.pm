# File      : New.pm
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

package New;

$New::date = '$Date: 2000/04/09 02:54:02 $';
$New::revision = '$Id: New.pm,v 1.1 2000/04/09 02:54:02 child Exp $';
$New::VERSION = '0.1';

use strict;

sub new
{
    my($caller, $arg) = @_;
    my $callerIsObj = ref($caller);
    my $class = $callerIsObj || $caller;
    my $self = bless { }, $class;

    foreach ( keys %$arg ) {
        $self->{"_$_"} = $arg->{$_};
    }
    return $self;
}

sub Init
{
    my ($self, $arg) = @_;

    foreach ( keys %$arg ) {
        $self->{"_$_"} = $arg->{$_};
    }
}

sub Error      { my $self = $_[0]; $self->{_error}->SetError($_[1])   }
sub Debug      { my $self = $_[0]; $self->{_debug}->WriteLog("$_[1]") }

1;
