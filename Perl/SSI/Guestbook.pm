# This package contains all the functions to embedd a guestbook into offline generated pages
# using online SSI calls.

package SSI::Guestbook;

use strict;
use SSI::Config;
use CGI;
use Time::localtime;
use Mail::Send;

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
	my $text = shift;

	return $text;
}

sub i18n_safe() {
	my $self = shift;
	my $text = shift;

	return $text;
}

# This function returns the part to let users add their own entry
sub show_addItem() {
	my $self = shift;
	my $config = $self->{'config'};
	my $dbh = $config->dbh();
	my $q = $self->{'cgi_query'};
	my $ret = "";


	$ret .= $q->start_form({-method=>'GET', -class=>'additem', -action=>"$ENV{'DOCUMENT_URI'}"},);
	$ret .= $q->hidden({-name=>'mode', -value=>'add_item', -override=>'1'});

	$ret .= $q->start_table({-class=>'additem', -align=>'center'});

	$ret .= $q->Tr( $q->td($self->i18n("Name:")), $q->td($q->textfield({-name=>'name', -override=>'1', -value=>'', -size=>'50'}))  );
	$ret .= $q->Tr( $q->td($self->i18n("eMail:")), $q->td($q->textfield({-name=>'email',-override=>'1',-value=>'',-size=>'50'}))  );
	$ret .= $q->Tr( $q->td($self->i18n("Web address:")), $q->td($q->textfield({-name=>'web',-value=>'',-override=>'1' ,-size=>'50'}))  );
	$ret .= $q->Tr( $q->td({-colspan=>'2'}, $self->i18n("Add your comments here:")) );
	$ret .= $q->Tr( $q->td({-colspan=>'2'}, $q->textarea({-name=>'comments', -value=>'', -override=>'1', -rows=>'12', -cols=>'40'}) ));
	$ret .= $q->Tr( $q->td({-colspan=>'2', -height=>'10'})); # space
	$ret .= $q->Tr( $q->td({-colspan=>'2', -align=>'center'}, $q->submit( $self->i18n_safe("Add your comments ...")) ));
	$ret .= $q->Tr( $q->td({-colspan=>'2', -height=>'20'})); # space

	$ret .= $q->end_table . $q->end_form;

	return $ret;
}

# This function lists all the items of the guestbook on one page.
sub list_items() {
	my $self = shift;
	my $config = $self->{'config'};
	my $dbh = $config->dbh();
	my $q = $self->{'cgi_query'};
	my $ret = "";

	my $sth = $dbh->prepare(q(
		SELECT *
		FROM `bibletime_guestbook`
		WHERE guestbook_checked = "1"
		ORDER BY `guestbook_id`
		DESC
	)) || return "Prepare fehleschlagen: " . DBI->errstr;
	$sth->execute() || return "exec failed:<BR>" . DBI->errstr;

	# Read the matching records and print them out
 	while (my @data = $sth->fetchrow_array()) { #this loop prints all the news items
		my ($name, $email, $web, $comments, $date) = @data[0 ... 4];

		$email =~ s|@|<img src="/images/mail.png"/>|; #make unreadable for spam robots
		#$email =~ s/[.]/;dot;/; #make unreadable for spam robots

		$comments =~ s/<.*?>\n{0,}//g; # strip out HTML, although it have been stripped out on creation time when it was written into the DB
		$comments =~ s/(?:\n){2,}/<p\/>/g; # two newlines are a new paragraph
		$comments =~ s/(?:\n)/<br\/>/g; # one newline is a line break in html

		if ($name && $comments) { #we have a valid entry, each entry is in an own small table
			$ret .= $q->start_table({-class=>'item'});

			#my $dateString = ($date && $date ne '0000-00-00') ? $self->i18n("wrote on") . " " .  Date_to_Text_Long( split('-',$date) ) : $self->i18n("wrote");
			my ($year, $month, $day) = split('-',$date);
			my $dateString = ($date && $date ne '0000-00-00') ? $self->i18n("wrote on") . " $year-$month-$day" : $self->i18n("wrote");

			$ret .= $q->Tr(
				$q->td({-class=>'header'},
					$q->span({-class=>'name'}, $name),
					($email || $web) ? $q->span({-class=>"contact-info"},
						"(" . ($email ? $email : "") . ($web ? ($email ? ", " : "") . $q->a({-href=>$web =~ /^http:/ ? "$web" : "http://$web"}, "$web") : "") . ")",
					) : "",
					$dateString, ':'
				)
			);
			$ret .= $q->Tr( $q->td({-class=>'comments', -colspan=>'2'}, $comments ));

			$ret .= $q->end_table;
		};
	 }

	#return '<center>' . $ret . '</center>'; # center everything
	return $ret;
}

sub addItem {
	my $self = shift;
	my $config = $self->{'config'};
	my $dbh = $config->dbh();
	my $q = $self->{'cgi_query'};
	my $ret = "";

	my $name = $q->param('name');
	my $email = $q->param('email');
	my $web = $q->param('web');
	my $comments = $q->param('comments');

	#emails will be made unreadable for robots in the output script
	$comments =~ s/<.+?>// if ($comments); # remove HTML tags from comments

	if (!($name && $comments)) { #we must have these two values!
		return $q->h3($self->i18n("BibleTime Guestbook")) . $self->i18n("Please enter your name and the comment! The entry was not added to the guestbook!");
	};
	
	my $sth = $dbh->prepare(q(
		INSERT INTO bibletime_guestbook
		VALUES (?,?,?,?,?,0,LAST_INSERT_ID())
	)) || return "Prepare fehleschlagen: " . DBI->errstr;

	my ($year, $month, $day) = (localtime->year() + 1900, localtime->mon() +1, localtime->mday());
	my $today = "$year:$month:$day";
	
	$sth->execute (
		$name,
		$email,
		$web,
		$comments,
		$today
	) || return $q->h3($self->i18n("BibleTime Guestbook")) . $self->i18n("Your comments couldn't be written into the guestbook. The command to write the data to disk failed:") . $q->br() . $q->i(DBI->errstr);

	
	my $msg = new Mail::Send;	
	$msg->to('info@bibletime.info');
# 	$msg->('info@bibletime.info');
	$msg->subject('[Guestbook] BibleTime guestbook entry');
    	
	my $mail = <<EOF;
A new guestbook entry was added at now. The item must be confirmed in the admin area to be visible to all.
	Name:		$name
	eMail:		$email
	Web:		$web
	Comments: 	$comments
EOF

  	my $fh = $msg->open('sendmail');
	print $fh $mail;
    	$fh->close;
    	
	return $q->h3($self->i18n("Thank you for your comments!")) . $self->i18n("Your comments were sucessfully added to the guestbook! The BibleTime developers still have to check your comments if it's ok to post them. The comments will appear the next few days if nothing is wrong with them." . $q->br() . $q->br());

}

1;
