#!/usr/bin/perl
use HTML::Template;
use CGI qw/:standard option/;
use CGI::Carp qw(fatalsToBrowser);
use POSIX qw(locale_h);
use locale;

use URI;

$root="$ENV{'DOCUMENT_ROOT'}";
#$root="$ENV{'DOCUMENT_ROOT'}/bibletime/";

use base 'Locale::Maketext';
use Locale::Maketext::Lexicon {
    en => ['Auto'],
    de => ['Gettext' => "$root/po/de.po"]
};

#global variables, have to be set by the page render functions
@currentNavPos = [];
$sideBarHeader = "";


sub software_navigation() {
	$sideBarHeader = i18n("Software");
	return eval <<END;
q(<A HREF="index.cgi?type=Software_about&lang=$currentLang">) . i18n("About") . q(</A><br>)
. q(<A HREF="index.cgi?type=Software_news&lang=$currentLang">) . i18n("News") . q(</A><br>)
. q(<A HREF="index.cgi?type=Software_screenshots&lang=$currentLang">) . i18n("Screenshots") . q(</A><br>)
. q(<A HREF="index.cgi?type=Software_gallery&lang=$currentLang">) . i18n("Gallery") . q(</A><br>)
. q(<A HREF="index.cgi?type=Software_download&lang=$currentLang">) . i18n("Download") . q(</A><br>)
. q(<A HREF="index.cgi?type=Software_press&lang=$currentLang">) . i18n("In the press") . q(</A><br>)
. q(<A HREF="index.cgi?type=Software_license&lang=$currentLang">) . i18n("License") . q(</A>);
END
};

sub software_intro() {
	return eval<<END;
'<DIV CLASS="header">' .i18n("The BibleTime software") . '</DIV>'
. p(i18n("This section contains everything which is about the BibleTime software.<BR>In the news section you can follow BibleTime's current development and about our further plans with it."). " "
. i18n("The screenshots and gallery pages can be used to see how BibleTime looks and what things are possible with it."). " "
. i18n("The download page tells you have to download and install to get BibleTime running.") . " "
. i18n("All locations where BibleTime was covered are collected in the &raquo;In the press&laquo; section. The software license is added for completeness.")
);
END
};


sub software_about() {
	$ret = q(<DIV CLASS="header">) . i18n("About BibleTime") . q(</DIV>);
	$ret .= i18n("BibleTime is a free, powerful Bible study application for Unix systems.");

	return $ret;
};

sub software_news() {
	#read news from a file and return them as result of this function
	my $newsFileName = "$root/data/news.txt";
 	my $news_limit = 10;
 	my $t = "";
 	my $loop = 0;

 	open(NEWS, "< $newsFileName") or warn "Can't open $newsFileName";
 	#remove all newlines and create three records for the dates, questions and texts
 	undef $/;
 	my $whole_file = <NEWS>;
 	@items = split(/D:/,$whole_file);
 	my $insertSpacer = 0;
 	foreach(@items) {
	        if ($loop > $news_limit) {
                	last;
        	}
        	$loop = $loop+1;
        	($date, $subject, $author, $text) = split(/[SAT]:/, $_);

		$subject =~ s/\n//;
		$subject =~ s/^\s+//;

		$text =~ s/^\s+//;
		$text =~ s/\n+//g;

		$subject = i18n($subject);
		$text = i18n($text);

        	if ($date && $subject && $text && $author) {
	        	$t .= '<TABLE CLASS="news" CELLSPACING="0" WIDTH="100%">';
  			$t .= Tr( td({-class=>"news_heading"},$subject,font({-size => '-3', -color => '#6B0404'},
				i18n("Added by")." ".b($author)." ".i18n("on")." ".$date )) );
			$text =~ s/([a-zA-Z])/<FONT SIZE=\"+2\"><B>$1<\/B><\/FONT>/;
			$t .= Tr(td({class=>"news_text"},$text));
             		$t .= "</TABLE>";
        	}
 	}
 	close(NEWS);
 	return $t;
};

sub software_presscoverage() {
	return
i18n("On <A HREF=\"http://dot.kde.org/995302757\"><b>dot.kde.org</b></A> Andreas Pour draws the following conclusion in his review:")
. q(:<BR><P STYLE="padding-left:0.5cm;">
Bibletime is already a true godsend for religious KDE users.
It is easily useable though it may take a bit of time to learn some quirks.
I think the next release will make it even better, particularly by providing a GUI for the difficult
Sword installation/configuration. Besides this, my personal wishlist item is to use KHTML for its advanced navigation features.
<BR><SMALL>)
. i18n("Copyright of the review: &copy; 2001 Andreas \"Dre\" Pour. All rights reserved.").q(</SMALL></P>);
};

sub software_screenshots() {
	open(IN, "$root/data/screenshots.pl.txt") or return "Can't open gallery source code file. Please report this problem!";
	undef $/;
	$code = <IN>;

	return eval($code); #executes the code loaded from the file, will only work for translated pages when all messages are translated
};

sub software_gallery() {
	open(IN, "$root/data/gallery.pl.txt") or return "Can't open gallery source code file. Please report this problem!";
	undef $/;
	$code = <IN>;

	return eval($code); #executes the code loaded from the file, will only work for translated pages when all messages are translated
};

sub software_download() {
	return "";

};


sub software_license() {
	$ret = "";
	open(IN, "$root/data/gpl2.txt") or return "Can't open license file. Please report this problem!";

	undef $/;
	$ret = <IN>;

	return $ret;
};


######## Functions for the Modules part
sub modules_navigation() {
	$sideBarHeader = i18n("Text modules");
	return eval <<END;
q(<A HREF="index.cgi?type=Modules_bibles&lang=$currentLang">) . i18n("Bibles") . q(</A><br>
<A HREF="index.cgi?type=Modules_commentaries&lang=$currentLang">) . i18n("Commentaries") .q(</A><br>
<A HREF="index.cgi?type=Modules_lexicons&lang=$currentLang">) . i18n("Lexicons") . q(</A><br>
<A HREF="index.cgi?type=Modules_devotionals&lang=$currentLang">) . i18n("Devotionals") . q(</A><br>
<A HREF="index.cgi?type=Modules_cults&lang=$currentLang">) . i18n("Cults") .q(</A><br>
<A HREF="index.cgi?type=Modules_swordcd&lang=$currentLang">) . i18n("Get the Sword CD!") . q(</A><br>
<A HREF="index.cgi?type=Modules_copyright&lang=$currentLang">) . i18n("Copyright pages") . q(</A>);
END
};

sub modules_intro() {
	return eval<<END;
'<DIV CLASS="header">' .i18n("Texts for BibleTime") . '</DIV>' .
i18n("A module is a text which can used in BibleTime; it can either be a Bible, a commentary, a dictionary or a book.<BR>")
.i18n("BibleTime provides the functions to read, search, print and do other thngs with them.")
. p(i18n("The text modules itself are provided by the Crosswire, the Bible society which also supports the cool Sword project!"))
END
};


sub modules_bibles() {
	return "";
};

sub modules_commentaries() {
	return "";
};

sub modules_lexicons() {
	return "";

};

sub modules_devotionals() {
	return "";
};

sub modules_cults() {
	return "";
};

sub modules_swordcd() {
	open(IN, "$root/data/swordcdorder.pl.txt") or $ret = "Can't open Sword CD order source code file. Please report this problem!";
	undef $/;
	return eval(<IN>);
};

sub modules_swordcdconfirm() {
	open(IN, "$root/data/swordcdorderconfirm.pl.txt") or $ret = "Can't open Sord CD confirm source code file. Please report this problem!";
	undef $/;
	return eval(<IN>); #executes the code loaded from the file, will only work for translated pages when all messages are translated
};

sub modules_swordcdsend() {
	open(IN, "$root/data/swordcdordersend.pl.txt") or $ret = "Can't open Sord CD send source code file. Please report this problem!";
	undef $/;
	return eval(<IN>); #executes the code loaded from the file, will only work for translated pages when all messages are translated
};

sub modules_copyright() {
	return "";
};

######## Functions for the Documentation part
sub documentation_navigation() {
	$sideBarHeader = i18n("Documentation");
	return eval <<END;
q(<A HREF="index.cgi?type=Documentation_requirements&lang=$currentLang">) . i18n("Requirements") . q(</A><br>
<A HREF="index.cgi?type=Documentation_installation&lang=$currentLang">) . i18n("Installation") . q(</A><br>
<A HREF="index.cgi?type=Documentation_faq&lang=$currentLang">) . i18n("FAQ") . q(</A><br>);
END
};

sub documentation_intro() {
	return eval<<END;
END
};


sub documentation_requirements() {
	return "";

};

sub documentation_installation() {
	return "";
};

sub documentation_faq() {
	return "";
};


######## Functions for the Development part
sub development_navigation() {
	$sideBarHeader = i18n("Development");
	return eval <<END;
q(<A HREF="index.cgi?type=Development_assistance&lang=$currentLang">) . i18n("Assistance") . q(</A><br>
<A HREF="index.cgi?type=Development_join&lang=$currentLang">) . i18n("Join the team") . q(</A><br>
<A HREF="index.cgi?type=Development_mailinglists&lang=$currentLang">) . i18n("Mailing lists") . q(</A><br>);
END
};

sub development_intro() {
	return eval<<END;
END
};

sub development_assistance() {
	return "";

};

sub development_join() {
	return "";
};

sub development_mailinglists() {
	$ret = q(<DIV class="header">) .
i18n("Sword development mailing list</DIV>To subscribe to the development mailing list of the Sword project please send an email to majordomo\@crosswire.org with the body of the message containing subscribe sword-devel. Depending on your web browser, the following link may do this automatically:")
." ".a({-href=>'mailto:majordomo@crosswire.org?&body=subscribe%20sword-devel'},'majordomo@crosswire.org') . ".<br>"
.i18n("Archives of the Sword project development mailing list are available at")
." ".a({-href=>'http://www.bibletechnologieswg.org/cgi-bin/lwgate/sword-devel@crosswire.org'},'www.bibletechnologieswg.org/cgi-bin/lwgate/sword-devel@crosswire.org')
.q(<br><br><DIV CLASS="header">).
i18n("BibleTime development mailing list</DIV>To subscribe to the development mailing list of the BibleTime project please send an email to majordomo\@crosswire.org with the body of the message containing subscribe bt-devel. Depending on your web browser, the following link may do this automatically:")
.a({-href=>'mailto:majordomo@crosswire.org?&body=subscribe%20bt-devel'},'majordomo@crosswire.org') .".<br>"
.i18n("Archives of the BibleTime development mailing list are available at ")
.a({-href=>'http://www.bibletechnologieswg.org/cgi-bin/lwgate/bt-devel@crosswire.org'},'www.bibletechnologieswg.org/cgi-bin/lwgate/bt-devel@crosswire.org')
;
	return $ret;
};


######## Functions for the Feedback part
sub contact_navigation() {
	$sideBarHeader = i18n("Contact");
	return eval <<END;
q(<A HREF="index.cgi?type=Contact_guestbook&lang=$currentLang">) . i18n("Guestbook") . q(</A><br>)
. q(<A HREF="index.cgi?type=Contact_bugreport&lang=$currentLang">) . i18n("Report a bug") . q(</A><br>)
. q(<A HREF="index.cgi?type=Contact_supportrequest&lang=$currentLang">) . i18n("Get support") . q(</A><br>)
. q(<A HREF="index.cgi?type=Contact_featurerequest&lang=$currentLang">) . i18n("Post a new feature") . q(</A><br>)
. q(<A HREF="index.cgi?type=Contact_links&lang=$currentLang">) . i18n("Links") . q(</A><br>)
. q(<A HREF="index.cgi?type=Contact_linktous&lang=$currentLang">) . i18n("Link to us") . q(</A>);
END
};

sub contact_intro() {
	return eval<<END;
END
};

sub contact_bugreport() {
	return "";
};

sub contact_supportrequest() {
	return "";
};

sub contact_featurerequest() {
	return "";
};

sub contact_links() {
	return "";
};

sub contact_guestbook() {
	#insert the returned text by "cgi-bin/my_guestbook.pl"
	$ret=`cd $root/cgi-bin; perl my_guestbook.pl`;
	return $ret;
};


sub contact_linktous() {
	return q(<DIV CLASS="header">).
i18n("How to link to www.bibletime.de") .
q(</DIV>).
	i18n("There are three ways  you go use to link to us:")
	.q(<UL><LI><A HREF="#m1">).
		i18n("1. Larger banner")
		.q(</A></LI><LI><A HREF="#m2">).
		i18n("2. Smaller banner")
		.q(</A></LI><LI><A HREF="#m3">).
		i18n("3. Simple text link")
		.q(</A></LI></UL>).
	i18n("Please do not copy the images because they may change their design.")
	.q(<A NAME="m1">).
	i18n("1. Larger banner")
	.q(</A></B><BR>').
	i18n("Put the following HTML-code on your pages:")
	.q(<P STYLE="margin-left:5mm;">
                &lt;A HREF="http://www.bibletime.de" TARGET="_blank"&gt;<br>
                &lt;IMG SRC="http://www.bibletime.de/images/banner_big.jpg" WIDTH="468" HEIGHT="60" BORDER="0"&gt;<br>
                &lt;/A&gt;<br>
        </P>).
	i18n("This will look like this:")
	.'<BR>
        <P STYLE="margin-left:5mm;">
                <A HREF="http://www.bibletime.de" TARGET="_blank">
                <IMG SRC="images/banner_big.jpg" WIDTH="468" HEIGHT="60" BORDER="0">
                </A>
        </P>
	<B><A NAME="m2">'.
	i18n("2. Smaller banner")
	.'</A></B><BR>'.
	i18n("Put the following HTML-code on your pages:")
	.'<P STYLE="margin-left:5mm;">
                &lt;A HREF="http://www.bibletime.de/" TARGET="_blank"&gt;<br>
                &lt;IMG SRC="http://www.bibletime.de/images/banner_small.jpg" WIDTH="468" HEIGHT="60" BORDER="0"&gt;<br>
                &lt;/A&gt;<br>
        </P>'.
	i18n("This will look like this:")
	.q(<BR><P STYLE="margin-left:5mm;">
                <A HREF="http://www.bibletime.de" TARGET="_blank">
                <IMG SRC="images/banner_small.jpg" WIDTH="88" HEIGHT="31" BORDER="0">
                </A>
        </P>
	<B><A NAME="m3">).
	i18n("3. Text link")
	.q(</A></B><BR>).
	i18n("To insert a simple text link please use the following HTML code on your pages:")
	.q(<P STYLE="margin-left:5mm;">
                &lt;A HREF="http://www.bibletime.de/" TARGET="_blank"&gt;'
		.i18n("BibleTime - Bible study software for KDE").
		'&lt/A&gt;<br>
        </P>).
	i18n("This will look like this:")
	.q(<br>
        <P STYLE="margin-left:5mm;">
                <A HREF="http://www.bibletime.de" TARGET="_blank">).
		i18n("BibleTime - Bible study software for KDE")
		.q(</A></P>);
};



$lh = (param("lang") eq "") ? __PACKAGE__->get_handle : __PACKAGE__->get_handle(param("lang")); # magically gets the current locale
$currentLang = (param("lang") ne "") ? param("lang") : ($lg ? $lg->language_tag() : "");


sub i18n_failure_handler {
	my($failing_lh, $key, $params) = @_;
	my $lh_backup = __PACKAGE__->get_handle('en');

	#$url = "?lang=" . $lh->language_tag() . "&string=" . $key;

	$uri = URI->new( "/translate_string.pl", "http" );
	#$uri = uri_escape( '/translate_string.pl&lang=' . $lh->language_tag().'?string='.$key);
	#$url = $request->uri();
	$uri->query_form( lang =>$lh->language_tag(), string=>$key );
	$url = $uri->as_string();

	return '<font color="Red">'.$lh_backup->maketext($key,@params).'</font>' . '<SUP><B><A TARGET="_new" HREF="' . $url .'">' . i18n("translate") ."</A></B></SUP>";
};

sub i18n {  # it's just a shorthand
	if ($_[0] eq "translate") {
		return "translate";
	}
	return $lh->maketext(@_);
}

sub init_i18n() {
	setlocale(LC_ALL, $lh->language_tag()."_".uc($lh->language_tag()) );
	$lh->fail_with('i18n_failure_handler');
};



#initialize the i18n stuff for the webpages
init_i18n();

##### End of the sub declarations!
$typeParam = (param(type) ne "") ? "type=".param("type") : "";
my @flags = [
	{lang=>"de", link=>"index.cgi?$typeParam&lang=de"},
	{lang=>"en", link=>"index.cgi?$typeParam&lang=en"}
];

%types = (
	"Software" => {
		"about" => \&software_about,
		"news" => \&software_news,
		"screenshots" => \&software_screenshots,
		"gallery" => \&software_gallery,
		"download" => \&software_download,
		"press" => \&software_presscoverage,
		"license" => \&software_license,
	},
	"Modules" => {
		"bibles" => \&modules_bibles,
		"commentaries" => \&modules_commentaries,
		"lexicons" => \&modules_lexicons,
		"devotionals" => \&modules_devotionals,
		"cults" => \&modules_cults,
		"swordcd" => \&modules_swordcd,
		"swordcdconfirm" => \&modules_swordcdconfirm,
		"swordcdsend" => \&modules_swordcdsend,
		"copyright" => \&modules_copyright,
	},
	"Documentation" => {
		"requirements" => \&documentation_requirements,
		"installation" => \&documentation_installation,
		"faq" => \&documentation_faq,
	},
	"Development" => {
		"join" => \&development_join,
		"assistance" => \&development_assistance,
		"mailinglists" => \&development_mailinglists,
	},
	"Contact" => {
		"guestbook" => \&contact_guestbook,
		"bugreport" => \&contact_bugreport,
		"supportrequest" => \&contact_supportrequest,
		"featurerequest" => \&contact_featurerequest,
		"links" => \&contact_links,
		"linktous" => \&contact_linktous,
	}
);

%navpages = (
	"Software" => \&software_navigation,
	"Modules" => \&modules_navigation,
	"Documentation" => \&documentation_navigation,
	"Development" => \&development_navigation,
	"Contact" => \&contact_navigation,
);

%intropages = (
	"Software" => \&software_intro,
	"Modules" => \&modules_intro,
	"Documentation" => \&documentation_intro,
	"Development" => \&development_intro,
	"Contact" => \&contact_intro,
);


@commands = split('_', param("type"));
$section = "";
if (param("type") eq "") { #open the standard page (About BibleTime)
	@commands = ("Software");
}

if ($#commands >= 2) { # we assume that each array can't have more than two entries!
	$content = "\$#commands >= 2 !!!!<BR>This is impossible!<BR>ARGV[0] == ".param("type")."<BR>";
}
elsif ($#commands == 0) { #displayonly the navigation on the left
	$section = $commands[0];
	if ( $navpages{$section} ) { #function to get the kleys of the first group exists!
		$sidebar = $navpages{ $section }->();
	}
	else {
		$sidebar = "PROBLEM!";
	};
	$content = ($intropages{$section}) ? $intropages{$section}->() : "";
}
elsif ($command = $types{ $commands[0] }->{ $commands[1] }) {
	$section = $commands[0];
	if ($navpages{$section}) { #function to get the kleys of the first group exists!
		$sidebar = $navpages{ $section }->();
	}
	else {
		$sidebar = "PROBLEM!";
	};
	$content = $command->();
}
else {
	$content = "Command for ".param("type")." not found!";
}

@navButtons = [
	{navbutton => td( {-class=>(($section eq "Software") ? "activenavbutton" : "navbutton")}, ($section ne "Software") ? a({-href=>"index.cgi?type=Software&lang=$currentLang"},i18n("Software")) : i18n("Software") )},
	{navbutton => td( {-class=>(($section eq "Documentation") ? "activenavbutton" : "navbutton")}, ($section ne "Documentation") ? a({-href=>"index.cgi?type=Documentation&lang=$currentLang"},i18n("Documentation")) : i18n("Documentation") )},
	{navbutton => td( {-class=>(($section eq "Modules") ? "activenavbutton" : "navbutton")}, ($section ne "Modules") ? a({-href=>"index.cgi?type=Modules&lang=$currentLang"},i18n("Text modules")) : i18n("Text modules") )},
	{navbutton => td( {-class=>(($section eq "Contact") ? "activenavbutton" : "navbutton")}, ($section ne "Contact") ? a({-href=>"index.cgi?type=Contact&lang=$currentLang"},i18n("Contact")) : i18n("Contact") )},
	{navbutton => td( {-class=>(($section eq "Development") ? "activenavbutton" : "navbutton")}, ($section ne "Development") ? a({-href=>"index.cgi?type=Development&lang=$currentLang"},i18n("Development")) : i18n("Development") )},
];


# main part of the program
my $template = HTML::Template->new(filename => 'basic_page.tmpl', path => [ 'dynamic-templates/' ]);
$template->param(
	PAGE_TITLE => i18n("The BibleTime homepage"),
	FLAGS => @flags,
	NAV_BUTTONS => @navButtons,
	VISITORS => i18n("visitors since 1999-06-23"),
	SIDEBARHEADER => $sideBarHeader,
	SIDEBAR => $sidebar,
	CONTENT => $content,
);

print "Content-Type: text/html\n\n";
print $template->output;

