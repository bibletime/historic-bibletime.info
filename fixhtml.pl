#!/usr/bin/perl

sub fix_htmlfile() {
	my $file = shift;

	open(IN, "< $file");

	undef $/;
	my $content = <IN>;
	close(IN);

	#remove all xmlns="" crap and all lang=".+" tags
	$content =~ s/(\s)xmlns=""/$1/g;
	$content =~ s/\slang=".+?"/ /g;
	$content =~ s/(<a .+?)target=".+?"/$1/g;
	#$content =~ s/(<a .+?)id=".{}?"/$1/g;
	#$content =~ s/(<tr .+?)colspan=".+?"\s?/$1/g;
	$content =~ s/(<ol .+?)type="[0-9]"/$1/g;

	open(OUT, "> $file");
	print OUT $content;
	close(OUT);

	closedir(DIR);
}

my $file = $ARGV[0] or die "Need HTML files as input";

die "No HTML files!" unless ($file =~ /php4|html$/);

&fix_htmlfile($file);
