#!/usr/bin/perl

# This is a guestbook application for te XML docbook-xml-website based pages
# The different parts can be embedded online by using SSI calls in the generated HTML pages.
#
# This script should be usable for many situations and different pages.

# Copyright by Joachim Ansorg <joachim@ansorgs.de>

use lib 'Perl';
use CGI;
use SSI::SwordCD;
my $cgi = CGI->new();

my $sword_cd = SSI::SwordCD->new( $cgi );

print $cgi->header();

print $cgi->start_div({-class=>'swordcd'});

print $sword_cd->show_orderForm() unless ($cgi->param('mode'));
print $sword_cd->show_checkOrder() if ($cgi->param('mode') eq "check_order");
print $sword_cd->sendOrder() if ($cgi->param('mode') eq "send_order");

print $cgi->end_div();
