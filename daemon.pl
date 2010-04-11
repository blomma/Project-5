# !/usr/bin/perl -w
#
# File      : daemon.pl
# Author    : Mikael hultgren <micke@four04.com>
# Revision  : $Id: daemon.pl,v 1.25 2000/08/26 15:12:45 child Exp $
# Version   : 0.2
#
# Copyright (C) 2000 Mikael hultgren <mike@four04.com> four04.
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

BEGIN
{
    unshift (@INC, "lib");
}

use strict;
use Daemon;
use Base::Base;
use Account;
use Debug;
use Password;
use Smtp;
use Error;
use Io;
use Os;


# =--- Create a Error object
my $Error = new Error;

# =--- Get a Io objekt to use
# =--- we might need to kill ourselves
my $Io = new Io( { error => $Error } );

# =--- Check for arguments on the line
if( @ARGV )
{
    my $pid;
    unless( $pid = $Io->GetPid ) 
    {
        print "Couldn't find the pid for the process, are you sure it's running\n";
        exit;
    }

    $Io->KillPid($pid)    if $ARGV[0] eq 'kill';
    $Io->RestartPid($pid) if $ARGV[0] eq 'restart';
    print "The process isn't running\n" and exit
		if $Error->GetError;
    exit;
}

# =--- Create a Debug object
# =--- To include strace output add strace => 1
my $Debug = new Debug ( { error => $Error } );
$Debug->OpenLog;

# =--- Initialize the io object with debug handling
$Io->Init( { debug => $Debug } );

# =--- Create the rest of the objects
my $Daemon    = new Daemon     ( { error => $Error, debug => $Debug } );
my $Base      = new Base::Base ( { error => $Error, debug => $Debug } );
my $Os        = new Os         ( { error => $Error, debug => $Debug } );
my $Password  = new Password   ( { error => $Error, debug => $Debug } );
my $Smtp      = new Smtp
  (
	  {
		  error       => $Error,
			debug       => $Debug,
			from        => '',
			smtp_server => '',
			port        => 25
	  }
  );

my $Account   = new Account
  (
	  {
		  error    => $Error,
			debug    => $Debug,
			base     => $Base,
			os       => $Os,
			smtp     => $Smtp,
			password => $Password
	  }
  );


# =--- Catch interrupts and sigterms do a gracefull exit
$SIG{INT}  = sub { $SIG{'INT'}  = 'IGNORE'; $Debug->WriteLog("Recieved a INT signal"); exit(0) };
$SIG{TERM} = sub { $SIG{'TERM'} = 'IGNORE'; $Debug->WriteLog("Recieved a TERM signal"); exit(0) };

# =--- Fork into background
$Daemon->Init;
$Io->WritePid($Daemon->GetPid);

# =--- Check error status
if ( $Error->GetError )
{
    $Debug->WriteLog($Error->GetError);
    exit;
}

MAINLOOP:
for (;;)
{
    # =--- Check if connection to base is still active
    $Debug->WriteLog("Checking connection to database...")
	  if defined $Debug;
	
    unless ( $Base->CheckConnection )
	{
        $Debug->WriteLog("Connection is down") if defined $Debug;
        unless ( $Base->Connect ) {
            $Debug->WriteLog($Error->GetError) if defined $Debug;
            sleep 60;
            next MAINLOOP;
        }
    }
    $Debug->WriteLog("Connection Alive") if defined $Debug;

    # =--- Get pending accounts
    $Account->GetPendingAccounts;

    # =--- Process them
    $Account->ProcessAccounts;
    $Debug->WriteLog("Zzzzzz 60 secs")
	  if defined $Debug;
    sleep 60;
}
