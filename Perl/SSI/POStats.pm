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

		my $untranslatedPerc = sprintf("%i", $untranslated / $total * 100);
		if (!$untranslatedPerc) {
			$untranslatedPerc = 1;
		}

		my $fuzzyPerc = sprintf("%i", $fuzzy / $total * 100);
		if (!$fuzzyPerc) {
			$fuzzyPerc = 1;
		}

		my $translatedPerc = 100 - $untranslatedPerc - $fuzzyPerc;
		if ($translatedPerc < 1) {
			$translatedPerc = 1;
		}

	my $url = "http://cvs.sourceforge.net/viewcvs.py/*checkout*/bibletime/bibletime-website/$lang/po/full.po?content-type=text%2Fplain";

		$ret .= $q->p("$lang [" . $q->a({-href=>"$url"}, "Download as PO file ") . "]") . $q->div({-class=>"language"},
			$q->div({-style=>"width: $untranslatedPerc%;", -title=>"$untranslatedPerc%"}, ""),
			$q->div({-style=>"width: $fuzzyPerc%;", -title=>"$fuzzyPerc%"}, ""),
			$q->div({-style=>"width: $translatedPerc%;", -title=>"$translatedPerc%"}, ""),
		);
	}

	close(IN);

	return $ret;
}

1;
