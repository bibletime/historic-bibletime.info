#!/usr/bin/perl
# This script processes the makefiles and creates the file which contains the necessary
# entries so the SSI script can create the translation statistics

use lib "Perl";
use Locale::PO;
use strict;

# Create statistics for the given language
sub website_stats() {
	my $lang = shift || die "No language given";

	my $pofile = "$lang/po/full.po";

	my $translated = 0;
	my $untranslated = 0;
	my $fuzzy = 0;

	my $aref = Locale::PO->load_file_asarray("$pofile");
	my @entries = @$aref if ($aref);
	if ($#entries+1) {
		foreach my $entry (@entries) {
			my $msgid = $entry->dequote( $entry->msgid() );
			my $msgstr = $entry->dequote( $entry->msgstr() );

			my $no_msgid = !$msgid || ($msgid eq "") || (length($msgid) == 0);
			my $no_msgstr = !$msgstr || ($msgstr eq "") || (length($msgstr) == 0);

			if ($no_msgid) {
				next;
			}

			if ($no_msgstr) {
				++$untranslated;
			}
			elsif ($entry->fuzzy()) {
				++$fuzzy;
			}
			else {
				++$translated;
			}
		}
	}

	return "$lang \t$translated \t$untranslated \t$fuzzy\n";
}

# Create statistics for the given language
sub bibletime_stats() {
	my $sourcedir = shift;
	my $targetfile = shift;

	open(FILE, $targetfile);

	opendir(DIR, $sourcedir);

	while (my $pofile = readdir(DIR)) {
		next unless ($pofile =~ /(\.po)$/);

		my $translated = 0;
		my $untranslated = 0;
		my $fuzzy = 0;

		my $aref = Locale::PO->load_file_asarray("$pofile");
		my @entries = @$aref if ($aref);
		if ($#entries+1) {
			foreach my $entry (@entries) {
				my $msgid = $entry->dequote( $entry->msgid() );
				my $msgstr = $entry->dequote( $entry->msgstr() );

				my $no_msgid = !$msgid || ($msgid eq "") || (length($msgid) == 0);
				my $no_msgstr = !$msgstr || ($msgstr eq "") || (length($msgstr) == 0);

				if ($no_msgid) {
					next;
				}

				if ($no_msgstr) {
					++$untranslated;
				}
				elsif ($entry->fuzzy()) {
					++$fuzzy;
				}
				else {
					++$translated;
				}
			}
		}
		print FILE "$pofile \t$translated \t$untranslated \t$fuzzy\n";
	} # while

	close(FILE);

	return
}

open(OUT, "> website.txt");

#my @langs = ("bg", "de", "ko", "pt-br", "ro", "ru", "ua");
#foreach my $lang (@langs) {
#	print OUT &website_stats( $lang );
#
#}

close(OUT);

&bibletime_stats( "../bibletime-i18n/po", 					"> messages_stats.txt" );
&bibletime_stats( "../bibletime-i18n/po/howto", 		"> howto_stats.txt" );
&bibletime_stats( "../bibletime-i18n/po/handbook", 	"> handbook_stats.txt" );
