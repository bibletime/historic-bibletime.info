# This package contains all the functions to embedd a guestbook into offline generated pages
# using online SSI calls.

package SSI::POStats;

use strict;
use SSI::Config;
use CGI;

%SSI::SwordCD::country_map = ();

# Constructor
sub new {
	my $class = shift;
	my $self = { #hash which holds the configuration
		config => SSI::Config->new(),
		cgi_query => shift,
	};
	bless($self, $class);

	return $self;
};

sub i18n() {
	my $self = shift;
	my $ret = shift;

	return $ret;
}

sub i18n_safe() {
	my $self = shift;
	my $ret = shift;

	return $ret;
}

# This function returns the part to let users add their own entry
sub show_stats() {
	my $self = shift;
	my $config = $self->{'config'};
	my $dbh = $config->dbh();
	my $q = $self->{'cgi_query'};
	my $ret = "";

	my $file = "postats.txt";
	open(IN, "< $file");

	while (<IN>) {
		chomp;

		my ($lang, $translated, $untranslated, $fuzzy) = split("\t");
		$lang =~ s/\s//;

		my $total = $translated + $untranslated + $fuzzy;

		my $untranslatedPerc = sprintf("%.1f", $untranslated / $total * 100);
		my $untranslatedWidth = sprintf("%i", $untranslated / $total * 100);
		if ($untranslatedWidth > 0 && $untranslatedWidth < 1) {
			$untranslatedWidth = 1;
		}

		my $fuzzyPerc = sprintf("%.1f", $fuzzy / $total * 100);
		my $fuzzyWidth = sprintf("%i", $fuzzy / $total * 100);
		if ($fuzzyWidth > 0 && $fuzzyWidth < 1) {
			$fuzzyWidth = 1;
		}

		my $translatedPerc = sprintf("%.1f", $translated / $total * 100);
		my $translatedWidth = 100 - $fuzzyPerc - $untranslatedPerc;
		if ($translatedWidth > 0 && $translatedWidth < 1) {
			$translatedWidth = 1;
		}

		#my $url = "http://cvs.sourceforge.net/viewcvs.py/*checkout*/bibletime/bibletime-website/$lang/po/full.po?rev=HEAD";
		my $url = "/$lang/po/full.po";
		$ret .= $q->div({-class=>"language"},
			$q->p("$lang [" . $q->a({-href=>"$url"}, "Download as PO file") . "]:", "$translatedPerc% translated, $fuzzyPerc% need revision, $untranslatedPerc% untranslated"),
			$q->div({-style=>"width: $translatedWidth%;", -title=>"$translatedPerc% translated"}, ""),
			$q->div({-style=>"width: $fuzzyWidth%;", -title => "$fuzzyPerc% fuzzy"}, ""),
			$q->div({-style=>"width: $untranslatedWidth%;", -title=>"$untranslatedPerc% untranslated"}, ""),
		);
	};

	close(IN);

	return $ret;
}

1;
