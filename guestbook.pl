#!/usr/bin/perl

# This is a guestbook application for te XML docbook-xml-website based pages
# The different parts can be embedded online by using SSI calls in the generated HTML pages.
#
# This script should be usable for many situations and different pages.

# Copyright by Joachim Ansorg <joachim@ansorgs.de>

use lib 'Perl';
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use SSI::Guestbook;

my $cgi = CGI->new();
my $guestbook = SSI::Guestbook->new( $cgi );

print $cgi->header();

print $cgi->start_div({-class=>'guestbook'});

print $guestbook->addItem() if ($cgi->param('mode') eq "add_item");
print $guestbook->show_addItem();
print $guestbook->list_items();

print $cgi->end_div();
