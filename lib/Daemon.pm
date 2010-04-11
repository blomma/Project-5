# File      : Daemon.pm
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

package Daemon;
use New;
@ISA = qw( New );

$Daemon::date = '$Date: 2000/04/09 03:13:50 $';
$Daemon::revision = '$Id: Daemon.pm,v 1.6 2000/04/09 03:13:50 child Exp $';
$Daemon::VERSION = '0.2';

use strict;
use POSIX qw(setsid);

sub Fork
{
    my ($self)= @_;

    my ($pid);
	FORK: {
        if ( defined($pid = fork) ) {
            return $pid;
        } elsif ( $! =~ /No more process/ ) {
            $self->Debug("No more processes, sleeping 5 secs and retrying") if defined $self->{_debug};
            sleep 5;
            redo FORK;
        } else {
            $self->Error("Couldn't fork: $!");
        }
    }
}

sub Init
{
    my ($self)= @_;

    my($pid, $sess_id, $i);

    #=--- Fork and exit parent
    if ( $pid = Fork )
	{
        exit 0;
    }

    # =--- Detach ourselves from the terminal
    $self->Error("Coudn't detach from controlling terminal")
	  unless $sess_id = setsid;

    $self->SetPid($sess_id);

    # =--- Change working directory
    chdir "/" or $self->Error("Couldn't chroot to /: $!");

    # =--- Clear file creation mask
    umask 0 or $self->Error("Couldn't set umask: $!");

    # =--- Reopen stderr, stdout, stdin to /dev/null
    open(STDIN,  "+>/dev/null") or $self->Error("couldnt dupe STDIN: $!");
    open(STDOUT, "+>&STDIN")    or $self->Error("couldnt dupe STDOUT: $!");
    open(STDERR, "+>&STDIN")    or $self->Error("couldnt dupe STDERR: $!");
}

sub GetVersion { my $self = $_[0]; return $Daemon::VERSION }
sub GetPid     { my $self = $_[0]; return $self->{_pid}    }
sub SetPid     { my $self = $_[0]; $self->{_pid} = $_[1]   }

1;

