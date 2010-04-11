# File      : BaseConf.pm
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

package Base::BaseConf;

$Base::BaseConf::date = '$Date: 2000/04/06 14:24:44 $';
$Base::BaseConf::revision = '$Id: BaseConf.pm,v 1.1 2000/04/06 14:24:44 child Exp $';
$Base::BaseConf::VERSION = '0.1';

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(@EXPORT_OK);

@EXPORT_OK = qw($connectString $attrString);
use vars qw($connectString $attrString);

$connectString = {
                  connect => 'dbi:Pg:dbname=account;host=localhost',
                  baseUser => 'account',
                  basePass => ''
};

$attrString = {
               PrintError => 1,
               AutoCommit => 1,
               RaiseError => 1
};
