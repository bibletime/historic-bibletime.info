# This package contains all the functions to embedd a guestbook into offline generated pages
# using online SSI calls.

package SSI::SwordCD;

use strict;
use SSI::Config;
use CGI;
use Date::Calc qw(Date_to_Text_Long Today);
use Mail::Sender;

%SSI::SwordCD::country_map = ();

# Constructor
sub new {
	my $class = shift;
	my $self = { #hash which holds the configuration
		config => SSI::Config->new(),
		cgi_query => shift,
	};
	bless($self, $class);

#	if (!%SSI::SwordCD::country_map) {
		%SSI::SwordCD::country_map = (
			"Unknown"			=> 	$self->i18n_safe("-- Not in this list!"),
			"Austria" 		=>	$self->i18n_safe("Austria"),
			"Belgium" 		=>	$self->i18n_safe("Belgium"),
			"Croatia" 		=> 	$self->i18n_safe("Croatia"),
			"Czech Republic"	=>	$self->i18n_safe("Czech Republic"),
			"Denmark"			=>	$self->i18n_safe("Denmark"),
			"Finland"			=>	$self->i18n_safe("Finland"),
			"France"			=>	$self->i18n_safe("France"),
			"Germany"			=>	$self->i18n_safe("Germany"),
			"Greece"			=>	$self->i18n_safe("Greece"),
			"Gibraltar"		=>	$self->i18n_safe("Gibraltar"),
			"Hungary"			=>	$self->i18n_safe("Hungary"),
			"Ireland"			=>	$self->i18n_safe("Ireland"),
			"Italy"				=>	$self->i18n_safe("Italy"),
			"Netherlands"	=>	$self->i18n_safe("Netherlands"),
			"Norway"			=>	$self->i18n_safe("Norway"),
			"Poland"			=>	$self->i18n_safe("Poland"),
			"Portugal"		=>	$self->i18n_safe("Portugal"),
			"Romania"			=>	$self->i18n_safe("Romania"),
			"Russia"			=>	$self->i18n_safe("Russia"),
			"Slovakia"		=>	$self->i18n_safe("Slovakia"),
			"Slovenia"		=>	$self->i18n_safe("Slovenia"),
			"Spain"				=>	$self->i18n_safe("Spain"),
			"Sweden"			=>	$self->i18n_safe("Sweden"),
			"Switzerland"	=>	$self->i18n_safe("Switzerland"),
			"Turkey"			=>	$self->i18n_safe("Turkey"),
			"Unkraine		"	=>	$self->i18n_safe("Ukraine"),
			"United Kingdom"	=>	$self->i18n_safe("United Kingdom"),
			"Yugoslavia"	=>	$self->i18n_safe("Yugoslavia"),
		);
#	};

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
sub show_orderForm() {
	my $self = shift;
	my $config = $self->{'config'};
	my $dbh = $config->dbh();
	my $q = $self->{'cgi_query'};
	my $ret = "";

	my @countries = sort {uc($a) cmp uc($b)} values( %SSI::SwordCD::country_map );

	$ret .= $q->start_form({-method=>"GET", -action=>"$ENV{'DOCUMENT_URI'}"},);
	$ret .= $q->hidden({-name=>'mode', -value=>'check_order', -override=>'1'});

	$ret .= $q->start_table({-cellpadding=>'2', -cellspacing=>'5'});

	$ret .= $q->Tr(
		$q->td(
			$self->i18n("Your full name:")
		),
		$q->td(
			$q->textfield({-name=>'name',-size=>'35'})
		)
	);

	$ret .= $q->Tr(
		$q->td(
			$self->i18n("Your street and number:")
		),
		$q->td(
			$q->textfield({-name=>'street',-size=>'35'})
		)
	);

	$ret .= $q->Tr(
		$q->td(
			$self->i18n("Your town:")
		),
		$q->td(
			$q->textfield({-name=>'town',-size=>'35'})
		)
	);

	$ret .= $q->Tr(
		$q->td(
			$self->i18n("Your country:")
		),
		$q->td(
			$q->popup_menu({-name=>'country', -values=>\@countries, -default=>$self->i18n_safe("United Kingdom")})
		)
	);

	$ret .= $q->Tr(
		$q->td(
			$self->i18n("How many CDs do you want?")
		),
		$q->td(
			$q->popup_menu({-name=>'cds',-values=>["1","2","3","4","5"], -default=>'1'})
		)
	);

	$ret .= $q->Tr(
		$q->td(
			$self->i18n("Your eMail address:")
		),
		$q->td(
			$q->textfield({-name=>'email',-size=>'35'})
		)
	);

	$ret .= $q->Tr(
		$q->td(
			$self->i18n("Comments / Notes:")
		),
		$q->td(
			$q->textarea({-name=>'comments',-cols=>'35', -rows=>'10'})
		)
	);

	$ret .= $q->Tr(
		$q->td({-colspan=>"2"},
			$q->submit($self->i18n_safe("Check order")),
			"&nbsp;&nbsp;",
			$q->reset($self->i18n_safe("Reset order"))
		)
	);

	$ret .= $q->end_table . $q->end_form;

	return $ret;
}


# This function returns the part to let users add their own entry
sub show_checkOrder() {
	my $self = shift;
	my $config = $self->{'config'};
	my $dbh = $config->dbh();
	my $q = $self->{'cgi_query'};
	my $ret = "Check";

	my %settings = (
		NAME => $q->param('name') || "",
		STREET => $q->param('street') || "",
		TOWN => $q->param('town') || "",
		COUNTRY => $q->param('country') || "",
		CDS => $q->param('cds') || "",
		EMAIL => $q->param('email') || "",
		COMMENTS => $q->param('comments') || "",
	);

	my $ret= undef;

	$ret.= $q->h3( $self->i18n("Please check the information you entered:") );

	$ret.= $q->start_table({-class=>'swordcdcheck'});
	$ret.= $q->Tr(
		$q->td($self->i18n("Name:")),
		$q->td("$settings{'NAME'}")
	);
	$ret.= $q->Tr(
		$q->td($self->i18n("Street:")),
		$q->td("$settings{'STREET'}")
	);
	$ret.= $q->Tr(
		$q->td($self->i18n("Town:")),
		$q->td("$settings{'TOWN'}")
	);
	$ret.= $q->Tr(
		$q->td($self->i18n("Country:")),
		$q->td("$settings{'COUNTRY'}" )
	);
	$ret.= $q->Tr(
		$q->td($self->i18n("eMail:")),
		$q->td("$settings{'EMAIL'}" )
	);
	$ret.= $q->Tr(
		$q->td({-colspan=>"2", -height=>'5px'})
	); # an empty line to seperate the information
	$ret.= $q->Tr(
		$q->td($self->i18n("Number of CDs:")),
		$q->td("$settings{'CDS'}" )
	);
	$ret.= $q->Tr(
		$q->td({-colspan=>"2", -height=>'5px'})
	); # an empty line to seperate the information
	$ret.= $q->Tr(
		$q->td($self->i18n("Your comments:")),
		$q->td("$settings{'COMMENTS'}" )
	);
	$ret.= $q->end_table();

	$ret.= $q->h3( $self->i18n("Is anything wrong there?") );
	$ret.= $q->p(
		$self->i18n("If anything is wrong in the information you provided please go back one page and correct it.")
	);
	$ret.= $q->p(
		$self->i18n("Otherwise, if everything is correct, please send the order by clicking on the button below.")
	);

	$ret.= $q->p(
		$self->i18n("The BibleTime developers will send you the CDs for free.")
	);


	# The form with the submit button
	$ret .= $q->start_form({-method=>"GET", -action=>"$ENV{'DOCUMENT_URI'}"},);
	$ret .= $q->hidden({-name=>'mode', -value=>'send_order', -override=>'1'});

	#provide the information the user entered again for the send page function
	$ret.= $q->hidden({-override => '1', -name=>'name', -value=>$settings{'NAME'}});
	$ret.= $q->hidden({-override => '1', -name=>'street', -value=>$settings{'STREET'}});
	$ret.= $q->hidden({-override => '1', -name=>'town', -value=>$settings{'TOWN'}});
	$ret.= $q->hidden({-override => '1', -name=>'country', -value=>$settings{'COUNTRY'}});
	$ret.= $q->hidden({-override => '1', -name=>'cds', -value=>$settings{'CDS'}});
	$ret.= $q->hidden({-override => '1', -name=>'email', -value=>$settings{'EMAIL'}});
	$ret.= $q->hidden({-override => '1', -name=>'comments', -value=>$settings{'COMMENTS'}});

	$ret.= $q->submit( $self->i18n_safe("Order the CDs!") );

	$ret.= $q->end_form();

	return $ret;

}

# This function returns the part to let users add their own entry
sub sendOrder() {
	my $self = shift;
	my $config = $self->{'config'};
	my $dbh = $config->dbh();
	my $q = $self->{'cgi_query'};
	my $ret;

	my %settings = (
		NAME 		=> $q->param('name') || "",
		STREET 	=> $q->param('street') || "",
		TOWN 		=> $q->param('town') || "",
		COUNTRY => $q->param('country') || "",
		CDS 		=> $q->param('cds') || "",
		EMAIL 	=> $q->param('email') || "",
		COMMENTS => $q->param('comments') || "",
	);
	my $success = 1;

	#check whether eMail etc. are valid
	if ($settings{'EMAIL'} !~ /^[a-z0-9-_.]+\@[a-z0-9-_.]+/i) {
		$ret .= $q->p(
			$self->i18n("The eMail adress") . " &raquo;$settings{'EMAIL'}&laquo; ".  $self->i18n("is incorrect!") 		);
		$ret .= $q->p(
			$self->i18n("Please use a valid eMail address!")
		);
		$success = 0;
	}
	if ($settings{'CDS'} !~ /[0-9]/) {
		$ret .= $q->p(
			$self->i18n("Please enter a correct amount of CD copies.")
		);
		$success = 0;
	}

	if ($success == 1) { #send out the eMails!
		# This one is the confirmation eMail!
		my $sender = new Mail::Sender {
			smtp => 'smtp.1und1.com',
			from => 'info@bibletime.info',
			charset => 'utf-8',
		};
		if (!ref($sender)) { #something went wrong!
			return $q->h3( $self->i18n("Order wasn\'t sent!") ) . $self->i18n("Something went wrong sending the eMails:") . $q->br() . $Mail::Sender::Error;
		};

		my $mail = <<"EOT";
Dear $settings{NAME},
this is the confirmation eMail of your Sword CD order you did at www.bibletime.info.
Here the information of your Sword CD order again to give you a reference for later questions you may have.

	Name: $settings{'NAME'}
	Street: $settings{'STREET'}
	Town: $settings{'TOWN'}
	Country: $settings{'COUNTRY'}
	eMail: $settings{'EMAIL'}
	Copies: $settings{'CDS'}

	Comments: $settings{'COMMENTS'}

If you have questions please send an eMail to info\@bibletime.info or simply respond to this eMail!

The BibleTime developers
EOT
	$sender->MailMsg({
		to => $settings{'EMAIL'},
		subject => 'Confirmation of your Sword CD order',
		msg => $mail,
	});


	$mail = <<"EOT";
	Name: $settings{'NAME'}
	Street: $settings{'STREET'}
	Town: $settings{'TOWN'}
	Country: $settings{'COUNTRY'}
	eMail: $settings{'EMAIL'}
	Copies: $settings{'CDS'}

	Comments: $settings{'COMMENTS'}
	IP: $ENV{'REMOTE_ADDR'}
EOT
		$sender->MailMsg ({
			subject => "[Sword CD order] " . $settings{'NAME'} . " ordered " . $settings{'CDS'} . "CD(s)",
			to => 'info@bibletime.info',
			from => $settings{'EMAIL'},
			msg => $mail
		});

		$ret .= $q->h3($self->i18n("CD order was sent successfully")) .
			$q->p(
				$self->i18n("The CD order was send to the BibleTime developers. You will get a confirmation eMail to make sure everything went right!")
			);
	}
	else {
		$ret =
			$q->h3($self->i18n("CD order was not sent")) .
			$ret .
			$q->p(
				$self->i18n("The CD order was NOT send to the BibleTime team. Please check the entered information!")
			);
	};
}

1;
