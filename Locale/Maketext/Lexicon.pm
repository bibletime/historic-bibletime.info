# $File: //member/autrijus/Locale-Maketext-Lexicon/lib/Locale/Maketext/Lexicon.pm $ $Author$
# $Revision$ $Change: 807 $ $DateTime: 2002/08/28 02:15:11 $

package Locale::Maketext::Lexicon;
$Locale::Maketext::Lexicon::VERSION = '0.09';

use strict;

=head1 NAME

Locale::Maketext::Lexicon - Use other catalog formats in Maketext

=head1 VERSION

This document describes version 0.09 of Locale::Maketext::Lexicon.

=head1 SYNOPSIS

As part of a localization class:

    package Hello::L10N;
    use base 'Locale::Maketext';
    use Locale::Maketext::Lexicon {de => [Gettext => 'hello_de.po']};

Alternatively, as part of a localization subclass:

    package Hello::L10N::de;
    use base 'Hello::L10N';
    use Locale::Maketext::Lexicon (Gettext => \*DATA);
    __DATA__
    # Some sample data
    msgid ""
    msgstr ""
    "Project-Id-Version: Hello 1.3.22.1\n"
    "MIME-Version: 1.0\n"
    "Content-Type: text/plain; charset=iso8859-1\n"
    "Content-Transfer-Encoding: 8bit\n"

    #: Hello.pm:10
    msgid "Hello, World!"
    msgstr "Hallo, Welt!"

    #: Hello.pm:11
    msgid "You have %quant(%1,piece) of mail."
    msgstr "Sie haben %quant(%1,Poststueck,Poststuecken)."

=head1 DESCRIPTION

This module provides lexicon-handling modules to read from other
localization formats, such as I<Gettext>, I<Msgcat>, and so on.

The C<import()> function accepts two forms of arguments:

=over 4

=item (I<format>, I<[ filehandle | filename | arrayref ]>)

This form pass the contents specified by the second argument to
B<Locale::Maketext::Lexicon::I<format>>->parse as a plain list,
and export its return value as the C<%Lexicon> hash in the calling
package.

=item { I<language> => [ I<format>, I<[ filehandle | filename | arrayref ]> ] ... }

This form accepts a hash reference.  It will export a C<%Lexicon>
into the subclasses specified by each I<language>, using the process
described above.  It is designed to alleviate the need to set up a
separate subclass for each localized language, and just use the catalog
files.

=back

=head1 NOTES

If you want to implement a new C<Lexicon::*> backend module, please note
that C<parse()> takes an array containing the B<source strings> from the
specified filehandle or filename, which are I<not> C<chomp>ed.  Although
if the source is an array reference, its elements will probably not contain
any newline characters.

The C<parse()> function should return a hash reference, which will be
assigned to the I<typeglob> (C<*Lexicon>) of the language module.  All
it amounts to is that if the returned reference points to a tied hash,
the C<%Lexicon> will be aliased to the same tied hash.

=cut

sub import {
    my $class = shift;
    return unless @_;

    my %entries;
    if (UNIVERSAL::isa($_[0], 'HASH')) {
	# a hashref with $lang as keys, [$format, $src] as values
	%entries = %{$_[0]};
    }
    else {
	%entries = ( '' => [ @_ ] );
    }

	if (@_ == 2) {
	# an array consisting of $format and $src
    }
    else {
	# incorrect number of arguments
    }

    while (my ($lang, $entry) = each %entries) {
	my ($format, $src) = @{$entries{$lang}}
	    or die "no format specified";

	my $export = caller;
	$export .= "::$lang" if length($lang);

	my @content;
	if (!defined($src)) {
	    # nothing happens
	}
	elsif (UNIVERSAL::isa($src, 'ARRAY')) {
	    # arrayref of lines
	    @content = @{$src};
	}
	elsif (UNIVERSAL::isa($src, 'GLOB')) {
	    no strict 'refs';

	    # be extra magical and check for DATA section
	    if (eof($src) and $src eq \*{caller()."::DATA"}) {
		# okay, the *DATA isn't initiated yet. let's read.
		require FileHandle;
		my $fh = FileHandle->new;
		$fh->open((caller())[1]) or die $!;

		while (<$fh>) {
		    # okay, this isn't foolproof, but good enough
		    last if /^__DATA__$/;
		}

		@content = <$fh>;
	    }
	    else {
		# fh containing the lines
		@content = <$src>;
	    }
	}
	elsif (ref($src)) {
	    die "Can't handle source reference: $src";
	}
	else {
	    # filename - open and return its handle
	    require FileHandle;
	    require File::Spec;

	    my $fh = FileHandle->new;
	    my @path = split('::', $export);

	    $src = (grep { -e } map {
		my @subpath = @path[0..$_];
		map { File::Spec->catfile($_, @subpath, $src) } @INC;
	    } -1 .. $#path)[-1] unless -e $src;

	    $fh->open($src) or die $!;
	    @content = <$fh>;
	}

	no strict 'refs';
	eval "use $class\::$format; 1" or die $@;
	*{"$export\::Lexicon"} = "$class\::$format"->parse(@content);
	push(@{"$export\::ISA"}, scalar caller) if $lang;
    }
}

1;

=head1 ACKNOWLEDGMENTS

Thanks to Jesse Vincent for suggesting this module to be written.

Thanks also to Sean M. Burke for coming up with B<Locale::Maketext>
in the first place, and encouraging me to experiment with alternative
Lexicon syntaxes.

=head1 SEE ALSO

L<Locale::Maketext>, L<Locale::Maketext::Lexicon::Auto>,
L<Locale::Maketext::Lexicon::Gettext>, L<Locale::Maketext::Lexicon::Msgcat>,
L<Locale::Maketext::Lexicon::Tie>

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2002 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
