# File      : Io.pm
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

package Io;
use New;
@ISA = qw( New );

$Io::date = '$Date: 2000/04/13 11:11:47 $';
$Io::revision = '$Id: Io.pm,v 1.3 2000/04/13 11:11:47 child Exp $';
$Io::VERSION = '0.1';

use strict;
use Fcntl qw(:DEFAULT :flock);

sub WritePid
{
    my ($self,$pid) = @_;

    sysopen(FH,"/var/run/account.pid", O_RDWR|O_CREAT) or $self->Error("Couldn't open /var/run/account.pid. Reason: $!\n");
    flock(FH, LOCK_EX) or $self->Error("Couldn't flock /var/run/account.pid. Reason: $!\n");
    select((select(FH), $| = 1)[0]);
    print FH "$pid\n";
    close (FH);
}

sub GetPid
{
    my ($self) = @_;

    open(PID, "< /var/run/account.pid") or $self->Error("Couldn't open /var/run/account.pid. Reason: $!\n") and return undef;
    my $pid = <PID>;
    close (PID);
    return $pid;
}

sub KillPid
{
    my ($self, $pid) = @_;
    kill("SIGTERM", $pid);
    print "The process is killed\n";
}

sub RestartPid
{
    my ($self, $pid) = @_;
    kill("SIGHUP", $pid);
    print "The process is restarted\n";
}

sub DESTROY
{
    my ($self) = @_;
    unlink("/var/run/account.pid") or $self->Error("Can't unlink /var/run/account.pid: $!");
}

sub GetVersion { my $self = $_[0]; return $Io::VERSION }

1;
