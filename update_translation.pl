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

		print "\tCreating POT $potfile\n";
	}


	closedir(DIR);
}


# 1st parameter is the dir with the english XML sources
# 2nd parameter is the dir where the PO files should be put
# 3rd parameter is the dir where the POT files are
# 4th parameter is the language name
sub update_po_files() {
	my $source = shift;
	my $dest = shift;
	my $potdir = shift;
	my $lang = shift;

	print "Making PO files for $lang\n";
	mkpath($dest);

	opendir(DIR, $source);

	while (my $file = readdir(DIR)) {
		next unless ($file =~ /(\.xml|\.docbook)$/);
		next if ($file eq "catalog.xml");
		next if ($file eq "index.xml");
		next if ($file eq "autolayout.xml");

		my $pofile = $dest . $file;
		$pofile =~ s/(\.xml|\.docbook)$/\.po/;

		print "\tCreating PO file $pofile\n";

		my $potfile = $potdir . $file;
		$potfile =~ s/(\.xml|\.docbook)$/\.pot/;

		if (-e $pofile) { # PO file exists already
			my $command = "msgmerge --no-wrap $pofile $potfile -o $pofile.new > /dev/null 2>&1";
			`$command`;

			if (compare($pofile, "$pofile.new") != 0) { #different
			#if (!compare($pofile, "$pofile.new")) { #different
				move("$pofile.new", $pofile);
				print "\t\tMerged in changes\n";
			}
			else {
				print "\t\tSame entries!\n";
			}
			unlink("$pofile.new");
		}
		else { #po file not yet there
			print "\t\tCopied file\n";
			copy($potfile, $pofile);

			#merge in the already translated entries of our previous webpages!
			# We use all files in compendium/$lang/*.po
			opendir(C_DIR, "$source/../compendium/$lang");
			my $compendium_files;
			my $first_compendium;
			while (my $compendium_file = readdir(C_DIR)) {
				next unless ($compendium_file =~ /\.po$/);
				if (!$first_compendium){
					$first_compendium = "$source/../compendium/$lang/$compendium_file";
					next;
				}
				$compendium_files .= " -C $source/../compendium/$lang/$compendium_file";
			}
			closedir(C_DIR);

			copy("$pofile", "$pofile-old");
			my $command = "msgmerge --no-wrap -D $source/../compendium/$lang $compendium_files --output=$pofile-tmp $first_compendium $pofile-old > /dev/null 2>&1";
			`$command`;

			$command = "msgcomm --no-wrap --more-than=1 --output=$pofile $pofile-tmp $pofile-old > /dev/null 2>&1";
			`$command`;

			unlink("$pofile-old");
			unlink("$pofile-tmp");
			print "\t\tMerged in old translations from $compendium_files\n\n";
		}
	}

	print "\n\n";

	closedir(DIR);
}

# 1st parameter is the dir with the english sources
# 2nd parameter is the dir where the PO files are
# 3rd parameter is the dir where the XML files should be put
sub make_xml_files() {
	my $source = shift;
	my $podir = shift;
	my $dest = shift;

	print "Creating XML files\n";
	opendir(DIR, $source);

	while (my $file = readdir(DIR)) {
		next unless ($file =~ /(\.xml|\.docbook)$/);
		next if ($file eq "catalog.xml");

		my $pofile = $podir . $file;
		$pofile =~ s/(\.xml|\.docbook)$/\.po/;

		# Mow fill into the empty msgstr fields the original english msgid
		# po2xml leavesslated entries out, that's not what we want

		#work on $pofile-full and fill in english translations
		copy("$pofile","$pofile-full");
		my $aref = Locale::PO->load_file_asarray("$pofile");
		my @entries = @$aref if ($aref);
		print "$pofile: " . ($#entries+1) ."\n";
		if ($#entries+1) {
			foreach my $entry (@entries) {
				#print "copied " . $entry->msgid() . "\n" if ($entry->msgstr());;
				my $msgid = $entry->dequote( $entry->msgid() );
				my $msgstr = $entry->dequote( $entry->msgstr() );
				my $no_msgstr = !$msgstr || ($msgstr eq "") || (length($msgstr) == 0);
				$entry->msgstr($msgid) if ($no_msgstr);
			}
		}
		die unless Locale::PO->save_file_fromarray("$pofile-full", \@entries);

		my $xmlfile = $dest . $file;

		print "\tCreating XML file $xmlfile\n";

		my $originalXML = "$source/$file";
		my $command = "po2xml $originalXML $pofile-full > $xmlfile";
		`$command`;

		unlink("$pofile-full");
	}
	print "\n\n";

	closedir(DIR);
}

sub make_makefile() {
	my $dest = shift;

	print "Creating Makefile\n";

	#copy all required files!
	#`cp -R $dest/../en/schema $dest/../en/xsl $dest/`;
	#cp $dest/../en/catalog.xml $dest/../en/VERSION $dest/`;
	#`cp $dest/../en/*.css $dest/`;
	`ln -s ../en/schema ../en/xsl ../en/catalog.xml ../en/VERSION $dest/`;

	open(OUT, "> $dest/Makefile");

print OUT <<'EOF';
PROC=SGML_CATALOG_FILES="catalog.xml" xsltproc
STYLEDIR=./xsl
TABSTYLE=$(STYLEDIR)/bibletime.xsl
STYLESHEET=$(TABSTYLE)
# Change the path in output-root to put your HTML output elsewhere
STYLEOPT= --stringparam output-root .

.PHONY : clean

all:
	make website

include ../en/depends.tabular

autolayout.xml: layout.xml
	$(PROC) --output $@ $(STYLEDIR)/autolayout.xsl $<
	make depends

%.html: autolayout.xml
	$(PROC) --output $@  $(STYLEOPT)  $(STYLESHEET)  $(filter-out autolayout.xml,$^)
	../fixhtml.pl $@

%.shtml: autolayout.xml
	$(PROC) --output $@  $(STYLEOPT)  $(STYLESHEET)  $(filter-out autolayout.xml,$^)
	../fixhtml.pl $@

depends: autolayout.xml
	$(PROC) --output depends.tabular $(STYLEOPT) $(STYLEDIR)/makefile-dep.xsl $<

EOF

	close(OUT);
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
	&update_po_files($ENV{"PWD"}. "/en",  $ENV{"PWD"} . "/$lang/po/", $ENV{"PWD"} . "/en/pot/",$lang);
	&make_xml_files($ENV{"PWD"}. "/en", $ENV{"PWD"} . "/$lang/po/", $ENV{"PWD"} . "/$lang/");
	&make_makefile("$lang");
	&run_make("$lang");
}
