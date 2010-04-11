# File      : Account.pm
# Author    : Mikael hultgren <micke@four04.com>
#
# Copyright 1999-2000 Mikael hultgren <mike@four04.com> four04.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies of the Software, its documentation and marketing & publicity
# materials, and acknowledgment shall be given in the documentation, materials
# and software packages that this Software was used.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

package Account;
use New;
@ISA = qw( New );

$Account::date = '$Date: 2000/08/26 15:12:48 $';
$Account::revision = '$Id: Account.pm,v 1.18 2000/08/26 15:12:48 child Exp $';
$Account::VERSION = '0.2';

use strict;

sub GetPendingAccounts
{
    my ($self) = @_;

    my $accounts;

    my $ref = $self->{_base}->SelectPendingAccounts;
    for ( @$ref )
	{
        my $id = $_->[0];
        push ( @{$self->{_pendingaccounts}->{$id}}, $_->[1] );
        push ( @{$self->{_pendingaccounts}->{$id}}, $_->[2] );
        push ( @{$self->{_pendingaccounts}->{$id}}, $_->[3] );
        push ( @{$self->{_pendingaccounts}->{$id}}, $_->[4] );
        push ( @{$self->{_pendingaccounts}->{$id}}, $_->[5] );
        push ( @{$self->{_pendingaccounts}->{$id}}, $_->[6] );
    }
	#    $self->{_pendingaccounts} = $accounts;
}

sub ProcessAccounts
{
    my ($self) = @_;

    my $pendingAccounts = $self->GetPendingAccount;
    $self->Debug("No pending accounts to process") if defined $self->{_debug} and !defined $pendingAccounts;
    foreach my $key ( keys %$pendingAccounts )
	{
        $self->Debug("Proccesing account $key") if defined $self->{_debug};
        my (
			$accountUserName,
			$accountPassword,
			$accountEmail,
			$accountRealName,
			$accountAddress,
			$accountAction
		) = $self->GetPendingAccount($key);

        $self->Debug("Checking if $accountUserName exists in system") if defined $self->{_debug};
        if ( $self->CheckAccountExists($accountUserName) )
		{
			#=--- Found a account with this name
            $self->Debug("Found a match for $accountUserName in system") if defined $self->{_debug};
            $self->{_smtp}->SendMailAccountExists($accountUserName,$accountEmail);
            $self->{_base}->RemoveAccount($key);
            next;
        }

        if ( $accountAction == 1 or $accountAction == 2 or $accountAction == 3 )
		{
            if ( $accountAction == 3 )
			{
                #=--- Create a new password for the bugger
                $accountPassword = $self->{_password}->CreatePass;
                $self->Debug("Created a new password $accountPassword for $accountUserName") if defined $self->{_debug};
            }

            $self->Debug("Creating a new account with $accountUserName and $accountPassword") if defined $self->{_debug};
            $self->CreateAccount($accountUserName,$self->{_password}->CryptPass($accountPassword));
            $self->{_base}->ActivateAccount($key);

            if ( $accountAction == 2 or $accountAction == 3 )
			{
                $self->{_smtp}->SendMailNewAccount($accountUserName,$accountPassword,$accountEmail,$accountRealName,$accountAddress);
            }
        } elsif ( $accountAction == 4 ) {
            #=--- Create a new password for the account and mail it
        } elsif ( $accountAction == 5 ) {
            #=--- Suspend the account
        } elsif ( $accountAction == 6 ) {
            #=--- Remove the account
        }
    }
}

sub CreateAccount
{
    my ($self,$accountUserName,$accountPassword) = @_;
    $self->Debug("Creating account") if defined $self->{_debug};
    $self->{_os}->CreateUser($accountUserName, $accountPassword);
}

sub SuspendAccount
{
    my ($self,$key,$Base) = @_;
    $self->Debug("Suspending Account $key") if defined $self->{_debug};
    $Base->SuspendAccount($key);
}

sub CheckAccountExists
{
    my ($self,$accountUserName) = @_;

    my ($user) = (getpwnam ("$accountUserName"))[0];
    unless (defined $user)
	{
        return undef;
    }
}

sub GetPendingAccount  { my $self = $_[0]; return @{ $self->{_pendinaccounts}->{$_[1]} } if defined $_[1]; return $self->{_pendingaccounts} }
sub GetVersion         { my $self = $_[0]; return $Account::VERSION                    }

1;
