# $File: //member/autrijus/Locale-Maketext-Lexicon/lib/Locale/Maketext/Lexicon/Auto.pm $ $Author$
# $Revision$ $Change: 345 $ $DateTime: 2002/07/16 20:07:35 $

package Locale::Maketext::Lexicon::Auto;
$Locale::Maketext::Lexicon::Auto::VERSION = '0.01';

use strict;

=head1 NAME

Locale::Maketext::Lexicon::Auto - Auto fallback lexicon for Maketext

=head1 SYNOPSIS

    package Hello::L10N;
    use base 'Locale::Maketext';
    use Locale::Maketext::Lexicon {
	en => ['Auto'],
	# ... other languages
    };

=head1 DESCRIPTION

This module builds a simple Lexicon hash that contains nothing but
C<( '_AUTO' => 1)>, which tells C<Locale::Maketext> that no localizing
is needed -- just use the lookup key as the returned string.

It is especially useful if you're starting to prototype a program,
and does not want deal with the localization files yet.

=head1 CAVEATS

If the key to C<->maketext> begins with a C<_>, C<Locale::Maketext> will
still throw an exception.  See <Locale::Maketext/CONTROLLING LOOKUP FAILURE>
for how to prevent it.

=cut

sub parse {
    return {'_AUTO' => 1};
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
