# File      : Connect.pm
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

package Base::Base;
use New;
@ISA = qw( New );

$Base::Base::date = '$Date: 2000/04/13 11:11:47 $';
$Base::Base::revision = '$Id: Base.pm,v 1.5 2000/04/13 11:11:47 child Exp $';
$Base::Base::VERSION = '0.1';

use strict;
use DBI;
use Base::BaseConf qw($connectString $attrString);

sub Connect {
    my ($self) = @_;

    $self->Debug("Connecting to database") if defined $self->{_debug};

    eval {
        $self->{_DB} = DBI->connect(
                                    "$connectString->{connect}",
                                    "$connectString->{baseUser}",
                                    "$connectString->{basePass}",
                                    $attrString
                                   );
    };

    if ($@) {
        $self->ErrorMsg("Can't connect to sql server. Reason $DBI::errstr");
        return undef;
    }
    return 1;
}

sub Disconnect {
    my ($self) = @_;
    $self->Debug("Disconnecting from the database") if defined $self->{_debug};
    $self->{_DB}->disconnect if defined $self->{_DB};
}

sub CheckConnection {
    my ($self) = @_;

    $self->Debug("Pinging database to see if coonection is up") if defined $self->{_debug};
    eval {
        $self->{_DB}->ping;
    };
    if ($@) {
        $self->Debug("Cant ping the database, connection lost somehow") if defined $self->{_debug};
        return undef;
    }
    return 1;
}

sub SelectPendingAccounts {
    my ($self) = @_;

    $self->Debug("Getting pending accounts") if defined $self->{_debug};

    my $ref;
    eval {
        $ref = $self->{_DB}->selectall_arrayref
          (
           "select useraccount.id, useraccount.username, useraccount.password,
            useraccount.email, useraccount.realname, useraccount.address,
            useraccount.action
            from useraccount where status = 2"
          );
    };
    if ($@) {
        $self->ErrorMsg("Couldn't get pending accounts. Reason $DBI::errstr");
        return undef;
    }
    return $ref;
}

sub ActivateAccount {
    my ($self, $key) = @_;

    $self->Debug("Activating account $key") if defined $self->{_debug};

    eval {
        $self->{_DB}->do
          (
           "update useraccount set status=1, action=0
            where useraccount.id = $key"
          );
    };
    if ($@) {
        $self->ErrorMsg("Couldn't update accounts. Reason $DBI::errstr");
        return undef;
    }
    return 1;
}

sub SuspendAccount {
    my ($self,$key) = @_;

    $self->Debug("Suspending account $key") if defined $self->{_debug};

    eval {
        $self->{_DB}->do("update useraccount set status=3,action=0 where useraccount.id = $key");
    };
    if ($@) {
        $self->ErrorMsg("Couldn't suspend account with id $key. Reason $DBI::errstr");
        return undef;
    }
    return 1;
}

sub RemoveAccount {
    my ($self,$key) = @_;

    $self->Debug("Removing account $key") if defined $self->{_debug};

    eval {
        $self->{_DB}->do("delete from useraccount where useraccount.id = $key");
    };
    if ($@) {
        $self->ErrorMsg("Couldn't remove account with id $key. Reason $DBI::errstr");
        return undef;
    }
    return 1;
}

sub InsertAccount {
    my ($self,$accountUserName,$accountPassword,$accountEmail,$accountAddress,$accountRealName,$accountStatus) = @_;

    $self->Debug("Creating a new account for $accountUserName") if defined $self->{_debug};

    eval {
        $self->{_DB}->do(
           "insert into useraccount(username,password,email,realname,address,status,action)
            values('$accountUserName','$accountPassword','$accountEmail','$accountRealName','$accountAddress',$accountStatus,2)"
          );
    };

    if ($@) {
        $self->ErrorMsg("Couldn't insert account. Reason $DBI::errstr");
        return undef;
    }
    return 1;
}

sub DESTROY {
    my ($self) = @_;
    $self->Disconnect;
}

sub GetVersion { return $Base::Base::VERSION }

1;
