#!/usr/bin/perl
use HTML::Template;
use HTML::Entities;
use CGI qw/:standard option/;
use CGI::Carp qw(fatalsToBrowser);
require Locale::PO;
require HTTP::Request;

$root="$ENV{'DOCUMENT_ROOT'}";
#$root="$ENV{'DOCUMENT_ROOT'}/bibletime/";

$lang = param("lang");
$string = param("string");
$translation = param("translation");
$filename = "$root/po/$lang.po";
$aref = Locale::PO->load_file_asarray($filename);


sub translationForm {
	if (param("string") eq "") {
		return '<DIV CLASS="header">Problem!</DIV>It\'s not possible to call this script with no text to translate!';
	};

	$ret = b("You selected the following text for a translation into your language (" . param("lang") . "):")
	. br
	. br
	. div({-style=>"width: 60%; font-size:larger;border:thin solid black; margin-left:50px; padding: 3mm;"}, decode_entities(param("string")) )
	. p("After you completed the translation press the Send button to finish your translation!")
	. p("Please enter the translation below in the box:");

	$ret .= start_form({-method=>'POST', -action => '/translate_string.pl'})
	. hidden({-name=>"action", -value=>"submit"})
	. hidden({-name=>"lang", -value=>param("lang")})
	. hidden({-name=>"string", -value=>param("string")});

	my $text = "";
	foreach $po (@$aref) {
		if ($po->msgid() eq $string ) { #found!
			$text = $po->msgstr();
			last;
		};
	};

	$ret .= textarea({-name=>"translation", -style=>"margin-left: 50px;", -cols=>"60", -rows=>"8", -value=>$text})
	. br
	. br
	. p('You can use the following text snippets to format the text: ')
	. ul(
li("<B>&lt;BR&gt;</B><BR>line break"),
li("<B>&lt;P&gt;</B><BR>new paragraph"),
	)
	. p("You don't have to use HTML encoded characters like &raquo; or similair, this will be done automatically!")	
	. br
	. input({-type=>"submit"})
	. end_form;
	
	return $ret;
};

sub writeTranslation {
	if ($translation eq "") {
		return "Please enter some text into the translation box! Empty translations are not possible!";
	};

	my $newpo = new Locale::PO (
	 -msgid=>$string,
         -msgstr=>$translation,
         -fuzzy=>0
	);

	#if the entry is already present replace the translation, othwerwise append the item
	my $found = 0;
	foreach $po (@$aref) {
		if ($po->msgid() eq $newpo->msgid() ) { #found!
			$po->msgstr( encode_entities($translation) );
			$found = 1;
			Locale::PO->save_file_fromarray($filename, $aref);
			last;
		};
	};

	if ($found == 0) {
		#print "Append to FILE!";
		push(@$aref, $newpo);
		Locale::PO->save_file_fromarray($filename, $aref);
	};


	return h3("Sucessful!") . p("The translation was written to disk! Pleas refresh the BibleTime webpages to see the changed translation!");
};

print "Content-Type: text/html\n\n";
if (param("action") eq "") {
	$content = translationForm();
}
else {
	$content = writeTranslation();
};

my $template = HTML::Template->new(filename => 'translate_page.tmpl', path => [ 'dynamic-templates/' ]);
$template->param(
	PAGE_TITLE => "BibleTime website translation",
	CONTENT => $content,
);


print $template->output;

