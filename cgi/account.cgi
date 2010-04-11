#!/usr/bin/perl -w
#
# File      : account.cgi
# Author    : Mikael hultgren <micke@four04.com>
# Revision  : $Id: account.cgi,v 1.3 2000/04/08 21:56:00 child Exp $
# Version   : 0.1
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

BEGIN {
    unshift (@INC, "lib");
}

#=---------- DEBUGGING -------------=#
use CGI::Carp qw(fatalsToBrowser);
#=----------------------------------=#

use strict;
use CGI;
$CGI::POST_MAX = 1024 *1;
$CGI::DISABLE_UPLOADS = 1;
use Error;
use Postgresql;
use Account;
use HTML::Template;

my $query = new CGI;
my $Error = new Error;
my $Account = new Account( error => $Error );

if ( $query->param() ) {
    my $accountUserName = $query->param('userName');
    my $accountPassword = $query->param('password');
    my $accountEmail    = $query->param('email');
    my $accountRealName = $query->param('realName');
    my $accountAddress  = $query->param('address');
    my $Account = new Account;

    if ( $Account->CheckAccountExists($accountUserName) ) {
        print $query->header;
        print "The username you requested already exists, go back in browser and try a new";
        exit;
    } else {
        my $Base = new Postgresql( error => $Error );
        $Base->Connect;
        $Base->InsertAccount($accountUserName,$accountPassword,$accountEmail,$accountAddress,$accountRealName,2);
        $Base->Disconnect;
        print $query->header;
        print "Youre request for an account has been sent";
        print "$Error->{_error}";
    }
} else {
    my $Template = new Template( filename => 'account.html' );
    my $form = qq !
<TABLE>
<TR>
  <TD>
    Username:
  </TD>
  <TD>
    <INPUT type="text" name="userName">
  </TD>
</TR>
<TR>
  <TD>
    Password:
  </TD>
  <TD>
    <INPUT type="text" name="password">
  </TD>
</TR>
<TR>
  <TD>
    Email:
  </TD>
  <TD>
    <INPUT type="text" name="email">
  </TD>
</TR>
<TR>
  <TD>
    Name:
  </TD>
  <TD>
    <INPUT type="text" name="realName">
  </TD>
</TR>
<TR>
  <TD>
    Address:
  </TD>
  <TD>
    <INPUT type="text" name="address">
  </TD>
</TR>
</TABLE>
    !;
    $Template->param( DISCLAIMER => '',
                      FORM   => $form,
                    );
    print $query->header;
    print $Template->output;
    exit;
}
