# File      : Smtp.pm
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

package Smtp;
use New;
@ISA = qw( New );

$Smtp::date = '$Date: 2000/08/26 15:12:48 $';
$Smtp::revision = '$Id: Smtp.pm,v 1.12 2000/08/26 15:12:48 child Exp $';
$Smtp::VERSION = '0.2';

use strict;
use Socket;
use Time::Local;
use MIME::QuotedPrint;

sub TimeToDate {
    #=--- convert a time() value to a date-time string according to RFC 822

    my $time = $_[0] || time;

    my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    my @wdays  = qw(Sun Mon Tue Wed Thu Fri Sat);

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)
        = localtime($time);

    # offset in hours
    my $offset  = sprintf "%.1f", (timegm(localtime) - time) / 3600;
    my $minutes = sprintf "%02d", ( $offset - int($offset) ) * 60;
    my $timeZone  = sprintf("%+03d", int($offset)) . $minutes;

    return join(" ",
                ($wdays[$wday] . ','),
                $mday,
                $months[$mon],
                $year+1900,
                sprintf("%02d", $hour) . ":" . sprintf("%02d", $min),
                $timeZone
               );
}

sub ValidAddress {
    my ($self,$addr) = @_;
    unless ($addr =~ /^[\w\-\.\!\%\+\/]+\@[a-zA-z0-9\-]+(\.[a-zA-Z0-9\-]+)*\.[a-zA-Z0-9\-]+$/) {
        return undef;
    }
}

sub Connect {
    my ($self, $port, $smtpAddress) = @_;
    my $connect = connect (S, pack_sockaddr_in($port, $smtpAddress));
    return $connect;
}

sub Send {
    my ($self,$arg) = @_;

    foreach ( keys %$arg ) {
        $self->{"_$_"} = $arg->{$_};
    }

    #=--- Check from address
    unless ( $self->ValidAddress($self->{_from}) ) {
        $self->Error("Invalid From: address") and return;
    }

    if ( !defined($self->{_smtp_server}) ) {
        $self->Error("Invalid smtp server") and return;
    }

    #=--- Get recipients
    my @recipients;

    {
        local $^W = 0;
        foreach my $v (split(/, */, $self->{_to}),split(/, */, $self->{_cc}),split(/, */, $self->{_bcc})) {
            unless ( $self->ValidAddress($v) ) {
                next;
            }
            #=--- Pack spaces
            $v =~ s/\s+/ /g;
            if (/<(.*)>/) {
                push @recipients, $1;
            } else {
                push @recipients, $v;
            }
        }
    }

    unless (@recipients) {
        $self->Error("No recipients specified") and return;
    }

    $self->{_date} = $self->TimeToDate;
    $self->{_content_type} = 'text/plain; charset="iso-8859-1"';
    $self->{_content_transfer_encoding} = 'quoted-printable';

    $self->{_message} =~ s/^\./\.\./gom if (defined $self->{_message});
    $self->{_message} =~ s/\r\n/\n/go if (defined $self->{_message});
    $self->{_message} = encode_qp( $self->{_message} ) if (defined $self->{_message});
    $self->{_message} =~ s/\n/\015\012/go if (defined $self->{_message});

    $self->{_client} = (gethostbyname('localhost'))[0] || 'localhost';
    $self->{_proto}  = (getprotobyname('tcp'))[2];

    unless ( socket S, AF_INET, SOCK_STREAM, $self->{_proto} ) {
        $self->Error("Socket creation failed. Reason: $!") and return;
    }

    $self->{_smtp_server} =~ s/\s+//go;
    my $smtpAddress = inet_aton $self->{_smtp_server};

    unless ( $smtpAddress ) {
        $self->Error("Couldn't resolve $self->{_smtp_server}") and return;
    }

    my $retried = 0;
    my ($connected);
    my $port = $self->{_port};

    while ( (not $connected = $self->Connect($port,$smtpAddress))
            and ( $retried < $self->{_retries} )) {
        $retried++;
        sleep 1;
    }
    unless ( $connected ) {
        $self->Error("Couldn't connect to $self->{_smtp_server}") and return;
    }

#    my($oldfh)  = select(S); $| = 1; select($oldfh);
    select((select(S), $| = 1)[0]);

    chomp($_ = <S>);
    if ( /^[45]/ or !$_ ) {
        $self->Error("Connect error on $self->{_smtp_server}") and return;
    }

    print S "HELO $self->{_client}\015\012";
    chomp($_ = <S>);
    if (/^[45]/ or !$_) {
        $self->Error("Hello error $_") and return;
    }

    print S "mail from: <$self->{_from}>\015\012";
    chomp($_ = <S>);
    if (/^[45]/ or !$_) {
        $self->Error("Mail From error $_") and return;
    }

    foreach my $to (@recipients) {
        print S "rcpt to: <$to>\015\012";
        chomp($_ = <S>);
        if (/^[45]/ or !$_) {
        $self->Debug("Error sending to  $to") and return;
        }
    }

    #=--- Start data part
    print S "data\015\012";
    chomp($_ = <S>);
    if (/^[45]/ or !$_) {
        $self->Error("Cannot send data $_") and return;
    }

    my $headers = 'MIME-Version: 1.0';
    $headers .= "\r\nContent-type: $self->{_content_type}" if defined $self->{_content_type};
    $headers .= "\r\nContent-transfer-encoding: $self->{_content_transfer_encoding}";

    $self->{_headers} = defined $self->{_headers} ? $self->{_headers}."\r\n".$headers : $headers;

    print S "To: $self->{_to}\r\n";
    print S "From: $self->{_from}\r\n";
    print S "Cc: $self->{_cc}\r\n" if defined $self->{_cc};
    print S "Reply-to: $self->{_reply_to}\r\n" if $self->{_reply_to};
    print S "X-Mailer: Perl Smtp $Smtp::VERSION\r\n";

    if ($self->{_headers}) {
        print S $self->{_headers},"\r\n";
    }

    print S "Subject: $self->{_subject}\r\n\r\n";
    print S "\015\012",$self->{_message},"\015\012.\015\012";

    chomp($_ = <S>);
    if (/^[45]/ or !$_) {
        $self->Error("Message transmission failed $_") and return;
    }

    print S "quit\015\012";
    $_ = <S>;
    close S;
}

sub SendMailNewAccount {
    my ($self, $accountUserName, $accountPassword, $accountEmail,$accountRealName,$accountAddress) = @_;

    $self->Debug("Sending a message to $accountEmail that $accountUserName has been created") if defined $self->{_debug};

    my $userMessage = qq !
        An account has been created for you
        Name: $accountRealName
        Address: $accountAddress
        Email: $accountEmail

        Username: $accountUserName
        Password: $accountPassword
    !;

    $self->Send(
                {
                 to      => $accountEmail,
                 message => $userMessage,
                 subject => 'Account created'
                }
               );

    my $adminMessage = qq !
        An account has been created for this person
        Name: $accountRealName
        Address: $accountAddress
        Email: $accountEmail

        Username: $accountUserName
        Password: $accountPassword
    !;

    $self->Send(
                {
                 to      => 'changeme@changeme.nu',
                 message => $adminMessage,
                 subject => 'Account created'
                }
               );
}

sub SendMailAccountExists {
    my ($self, $accountUserName,$accountEmail) = @_;

    $self->Debug("Sending a message to $accountEmail that $accountUserName already exists") if defined $self->{_debug};
    $self->Send(
                {
                 to      => $accountEmail,
                 message => "The Username $accountUserName exists, please choose another one",
                 subject => 'Error in creating account'
                }
               );
}

END {
    close(S);
}

1;
