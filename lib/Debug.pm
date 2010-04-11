# File      : Debug.pm
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

package Debug;
use New;
@ISA = qw( New );

$Debug::date = '$Date: 2000/04/13 11:11:47 $';
$Debug::revision = '$Id: Debug.pm,v 1.10 2000/04/13 11:11:47 child Exp $';
$Debug::VERSION = '0.3';

use strict;
use Fcntl qw(:DEFAULT :flock);

sub OpenLog
{
    my ( $self ) = @_;

    sysopen( FH, "/var/log/debug.log", O_RDWR|O_CREAT ) or $self->Error( "Couldn't open /var/log/debug.log. Reason: $!\n" );
    flock( FH, LOCK_EX ) or $self->Error( "Couldn't flock /var/log/debug.log. Reason: $!\n" );
    select( ( select(FH ), $| = 1 ) [0] );
    $self->{_FH} = *FH;
}

sub WriteLog
{
    my ( $self, $msg ) = @_;
    my $trace = $self->{_trace} ? $self->trace( ) : '';
    my $FH = $self->{_FH};
    print FH "--> DEBUG $trace ### $msg\n";
}

sub _trace
{
    my ( $self ) = @_;
    my @call = caller( 1 );
    my $line = $call[2];
    my $cnt = 2;

    my @stack;

    while( defined( $call[0] ))
	{
        my $caller = $call[0];
        @call = caller( $cnt );
        $call[3] = $caller
			if ( !defined( $call[3] ));
        unshift( @stack, $call[3] . ":" . $line );
        $line = $call[2];
        $cnt++;
    }
    return( "[" . join( " ", @stack ) . "]" );
}

sub CloseLog
{
    my ( $self ) = @_;
    $self->WriteLog( "Closing Debug filehandle" );
    close $self->{_FH}
	if defined $self->{_FH};
}

sub DESTROY
{
    my ( $self ) = @_;
    $self->CloseLog;
}

1;
