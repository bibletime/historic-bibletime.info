# $File: //member/autrijus/Locale-Maketext-Lexicon/lib/Locale/Maketext/Lexicon/Gettext.pm $ $Author$
# $Revision$ $Change: 806 $ $DateTime: 2002/08/28 02:14:09 $

package Locale::Maketext::Lexicon::Gettext;
$Locale::Maketext::Lexicon::Gettext::VERSION = '0.03';

use strict;

=head1 NAME

Locale::Maketext::Lexicon::Gettext - PO and MO file parser for Maketext

=head1 SYNOPSIS

Called via B<Locale::Maketext::Lexicon>:

    package Hello::L10N;
    use base 'Locale::Maketext';
    use Locale::Maketext::Lexicon {
	de => [Gettext => 'hello/de.mo'],
    };

Directly calling C<parse()>:

    use Locale::Maketext::Lexicon::Gettext;
    my %Lexicon = %{ Locale::Maketext::Lexicon::Gettext->parse(<DATA>) };
    __DATA__
    #: Hello.pm:10
    msgid "Hello, World!"
    msgstr "Hallo, Welt!"

    #: Hello.pm:11
    msgid "You have %quant(%1,piece) of mail."
    msgstr "Sie haben %quant(%1,Poststueck,Poststuecken)."

=head1 DESCRIPTION

This module implements a perl-based C<Gettext> parser for
B<Locale::Maketext>. It transforms all C<%1>, C<%2>, <%*>... sequences
to C<[_1]>, C<[_2]>, C<[_*]>, and so on.  It accepts either plain PO
file, or a MO file which will be translated back to PO file via the
C<msgunfmt> program automatically.

Since version 0.03, this module also looks for C<%I<function>(I<args...>)>
in the lexicon strings, and transform it to C<[I<function>,I<args...>]>.
Any C<%1>, C<%2>... sequences inside the I<args> will have their percent
signs (C<%>) replaced by underscores (C<_>).

The name of I<function> above should begin with a letter or underscore,
followed by any number of alphanumeric characters and/or underscores.
As an exception, the function name may also consist of a single asterisk
(C<*>) or pound sign (C<#>), which are C<Locale::Maketext>'s shorthands
for C<quant> and C<numf>, respectively.

As an additional feature, this module also parses MIME-header style
metadata specified in the null msgstr (C<"">), and add them to the
C<%Lexicon> with a C<__> prefix.  For example, the example above will
set C<__Content-Type> to C<text/plain; charset=iso8859-1>, without
the newline or the colon.

Any normal entry that duplicates a metadata entry takes precedence.
Hence, a C<msgid "__Content-Type"> line occurs anywhere should override
the above value.

=cut

sub parse {
    my $self = shift;
    my (%var, $key, @ret);
    my @metadata;

    # Check for magic string of MO files
    if ($_[0] =~ /^\x95\x04\x12\xde/ or $_[0] =~ /^\xde\x12\x04\x95/) {
	my ($tmpfh, $tmpfile);
	if (eval "use File::Temp; 1") {
	    ($tmpfh, $tmpfile) = File::Temp::tempfile();
	}
	else {
	    # make a reasonable tmpfile decision
	    use FileHandle;
	    $tmpfile = ($ENV{TEMP} || $ENV{TMPDIR} || '/tmp') . "/$$.tmp";
	    $tmpfh = FileHandle->new;
	    $tmpfh->open(">$tmpfile") or die $!;
	}

	print $tmpfh @_;
	close $tmpfh;

	# Convert it to PO format
	@_ = `msgunfmt $tmpfile`;
	unlink $tmpfile;
    }

    # Parse PO files; Locale::gettext objects are not yet supported.
    foreach (@_) {
	/^(msgid|msgstr) +"(.*)" *$/	? do {	# leading strings
	    $var{$1} = $2;
	    $key = $1;
	} :

	/^"(.*)" *$/			? do {	# continued strings
	    $var{$key} .= $1;
	} :

	/^#, +(.*) *$/			? do {	# control variables
	    $var{$1} = 1;
	} :

	/^ *$/ && %var			? do {	# interpolate string escapes
	    push @ret, (map transform($_), @var{'msgid', 'msgstr'})
		if length $var{msgstr};
	    push @metadata, parse_metadata($var{msgstr})
		if $var{msgid} eq '';
	    %var = ();
	} : ();
    }

    local $^W;	# no 'uninitialized' warnings, please.

    push @ret, map { transform($_) } @var{'msgid', 'msgstr'}
	if length $var{msgstr};
    push @metadata, parse_metadata($var{msgstr})
	if $var{msgid} eq '';

    return {@metadata, @ret};
}

sub parse_metadata {
    return map {
	/^([^\x00-\x1f\x80-\xff :=]+):\s*(.*)$/ ? ("__$1", $2) : ()
    } split(/\n+/, transform(pop));
}

sub transform {
    my $str = shift;
    $str =~ s/\\([0x]..|c?.)/qq{"\\$1"}/eeg;
    $str =~ s/[\~\[\]]/~$&/g;
    $str =~ s/(^|[^%\\])%([A-Za-z#*]\w*)\(([^\)]*)\)/"$1\[$2,".unescape($3)."]"/eg;
    $str =~ s/(^|[^%\\])%(\d+|\*)/$1\[_$2]/g;

    chomp $str;
    return $str;
}

sub unescape {
    my $str = shift;
    $str =~ s/(^|,)%(\d+|\*)(,|$)/$1_$2$3/g;
    return $str;
}

1;

=head1 SEE ALSO

L<Locale::Maketext>, L<Locale::Maketext::Lexicon>

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2002 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
