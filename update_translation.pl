#!/usr/bin/perl

use lib "Perl";
use File::Path;
use File::Copy;
use File::Compare;
use Locale::PO;
use strict;

# This script updates the translation in the folder given as parameter

# 1st parameter is the dir with the english XML sources
# 2nd parameter is the dir where the POT files should be put
sub update_pot_files() {
	my $source = shift;
	my $dest = shift;

	print "Making POT files\n";
	mkpath($dest);

	opendir(DIR, $source);

	while (my $file = readdir(DIR)) {
		next unless ($file =~ /(\.xml|\.docbook)$/);
		next if ($file eq "catalog.xml");

		my $potfile = $dest . $file;
		$potfile =~ s/(\.xml|\.docbook)$/\.pot/;

		my $command = "xml2pot $source/$file > $potfile";
		`$command`;

		print "\tCreating temporary POT $potfile\n";
	}

	print "Merging POT files.";
	`msgcat $dest/*.pot > $dest/full.pot.cat`;
	`rm $dest/*.pot`;
	move("$dest/full.pot.cat","$dest/full.pot");

	closedir(DIR);
}


# 1st parameter is the dir where the POT files are
# 2nd parameter is the dir where the PO files should be put
sub update_po_files() {
	my $potdir = shift;
	my $podir  = shift;

	print "Making PO file\n";
	mkpath($podir);

	my $potfile = "$potdir/full.pot";
	my $pofile  = "$podir/full.po";

	`msgmerge --no-wrap $pofile $potfile -o $pofile.new`;

	if (compare($pofile, "$pofile.new") != 0) { #different
		move("$pofile.new", $pofile);
		print "\t\tMerged in changes\n";
	}
	else {
		print "\t\tSame entries!\n";
	}
	unlink("$pofile.new");

	print "\n\n";

}

# 1st parameter is the dir with the english sources
# 2nd parameter is the dir where the PO files are
# 3rd parameter is the dir where the XML files should be put
sub make_xml_files() {
	my $source = shift;
	my $podir = shift;
	my $dest = shift;

	my $pofile = "$podir/full.po";

	print "Creating XML files\n";
	opendir(DIR, $source);

	while (my $file = readdir(DIR)) {
		next unless ($file =~ /(\.xml|\.docbook)$/);
		next if ($file eq "catalog.xml");

		print "\tCreating XML file $file\n";
		`po2xml $source/$file $pofile > $dest/$file`;
	}

	print "\n\n";

	closedir(DIR);
}

sub make_makefile() {
	my $dest = shift;

	print "Creating Makefile\n";

	copy("en/Makefile"       , "$dest/");
	copy("en/depends.tabular", "$dest/");
	copy("en/VERSION"        , "$dest/");
	copy("en/catalog.xml"    , "$dest/");
	copy("en/*.css"          , "$dest/");
}

sub run_make() {
	print "Calling \"make\"\n";
	my $lang = shift;
	`cd $lang && make clean && make`;
}

my $lang = $ARGV[0] || die "Please give a language to work on!";

#required for all languages
&update_pot_files($ENV{"PWD"} . "/en",  $ENV{"PWD"} . "/en/pot/");

while ($lang = shift(@ARGV)) {
	if ($lang eq "en") {
		next;
	}

	print "Working on $lang ...\n";
	&update_po_files($ENV{"PWD"} . "/en/pot/", $ENV{"PWD"} . "/$lang/po/");
	&make_xml_files($ENV{"PWD"}. "/en", $ENV{"PWD"} . "/$lang/po/", $ENV{"PWD"} . "/$lang/");
	&make_makefile("$lang");
	&run_make("$lang");
}
