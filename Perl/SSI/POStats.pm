# This package contains all the functions to embedd a guestbook into offline generated pages
# using online SSI calls.

package SSI::POStats;

use strict;
use SSI::Config;
use CGI;

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

	my $file = shift || die "No filename given";
	my $link_template = shift || die "No URL template given";

	open(IN, "< $file");

	while (<IN>) {
		chomp;

		my ($lang, $translated, $untranslated, $fuzzy) = split("\t");
		$lang =~ s/\s//;

		my $total = $translated + $untranslated + $fuzzy;

		my $untranslatedPerc = sprintf("%.1f", $untranslated / $total * 100);
		my $untranslatedWidth = sprintf("%i", $untranslated / $total * 100);
		if ($untranslatedPerc > 0 && $untranslatedPerc < 1) {
			$untranslatedWidth = 1;
		}

		my $fuzzyPerc = sprintf("%.1f", $fuzzy / $total * 100);
		my $fuzzyWidth = sprintf("%i", $fuzzy / $total * 100);
		if ($fuzzyPerc > 0 && $fuzzyPerc < 1) {
			$fuzzyWidth = 1;
		}

		my $translatedPerc = sprintf("%.1f", $translated / $total * 100);
		my $translatedWidth = 100 - $fuzzyWidth - $untranslatedWidth;
		if ($translatedPerc > 0 && $translatedPerc < 1) {
			$translatedWidth = 1;
		}

		my $url = $link_template;
		$url =~ s/\$lang/$lang/g;

		my $colspan = 3;
		--$colspan if ($translatedWidth == 0);
		--$colspan if ($fuzzyWidth == 0);
		--$colspan if ($untranslatedWidth == 0);

		$ret .= $q->table({-class=>"language", -cellspacing=>"0", -cellpadding=>'0'},
			$q->Tr(
				$q->td({-colspan=>"$colspan"},
					"$lang [" . $q->a({-href=>"$url"}, "Download as PO file") . "]:", "$translatedPerc% translated, $fuzzyPerc% need revision, $untranslatedPerc% untranslated"
				)
			),
			$q->Tr(
				($translatedWidth > 0)
					? $q->td({-class=>'translated', -width=>"$translatedWidth%", -title=>"$translatedPerc% translated"}, "")
					: "",
				($fuzzyWidth > 0)
					? $q->td({-class=>'fuzzy', -width=>"$fuzzyWidth%", -title => "$fuzzyPerc% fuzzy"}, "")
					: "",
				($untranslatedWidth > 0)
				? $q->td({-class=>'untranslated', -width=>"$untranslatedWidth%", -title=>"$untranslatedPerc% untranslated"}, "")
				: ""
			)
		);
	};

	close(IN);

	return $ret;
}

1;
