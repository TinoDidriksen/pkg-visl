#!/usr/bin/env perl
# -*- mode: cperl; indent-tabs-mode: nil; tab-width: 3; cperl-indent-level: 3; -*-
use utf8;
use strict;
use warnings;
BEGIN {
	$| = 1;
	binmode(STDIN, ':encoding(UTF-8)');
	binmode(STDOUT, ':encoding(UTF-8)');
}
use open qw( :encoding(UTF-8) :std );

use Getopt::Long;
my %opts = (
	'm' => 'Tino Didriksen <tino@didriksen.cc>',
	'e' => 'Tino Didriksen <tino@didriksen.cc>',
	'dv' => 1,
	'fv' => 1,
);
GetOptions(
	'm=s' => \$opts{'m'},
	'e=s' => \$opts{'e'},
	'distv=i' => \$opts{'dv'},
	'flavv=i' => \$opts{'fv'},
);

my %distros = (
	'wheezy' => 'debian',
	'jessie' => 'debian',
	'sid' => 'debian',
	'precise' => 'ubuntu',
	'saucy' => 'ubuntu',
	'trusty' => 'ubuntu',
	'utopic' => 'ubuntu',
);

print `rm -rf /tmp/autopkg.*`;
print `mkdir -pv /tmp/autopkg.$$`;
chdir "/tmp/autopkg.$$" or die "Could not change folder: $!\n";

print `svn export http://visl.sdu.dk/svn/visl/tools/trie-tools/include/tdc_trie.hpp`;
my $major = 0;
my $minor = 0;
my $patch = 0;
my $revision = `svn log -q -l 1 http://visl.sdu.dk/svn/visl/tools/trie-tools/ | egrep -o '^r[0-9]+' | egrep -o '[0-9]+'` + 0;
{
	local $/ = undef;
	open FILE, 'tdc_trie.hpp' or die "Could not open tdc_trie.hpp: $!\n";
	my $data = <FILE>;
	($major,$minor,$patch) = ($data =~ m@TRIE_VERSION_MAJOR = (\d+);.*?TRIE_VERSION_MINOR = (\d+);.*?TRIE_VERSION_PATCH = (\d+);@s);
	close FILE;
}

my $version = "$major.$minor.$patch.$revision";
my $date = `date -u -R`;

print `svn export http://visl.sdu.dk/svn/visl/tools/trie-tools/ 'trie-tools-$version'`;
`find 'trie-tools-$version' ! -type d | LC_ALL=C sort > orig.lst`;
print `tar -jcvf 'trie-tools_$version.orig.tar.bz2' -T orig.lst`;
print `svn export http://visl.sdu.dk/svn/visl/opensource/packaging/trie-tools/debian/ 'trie-tools-$version/debian/'`;

foreach my $distro (keys %distros) {
	my $chver = $version.'-';
	if ($distros{$distro} eq 'ubuntu') {
		$chver .= "0ubuntu";
	}
	$chver .= $opts{'dv'}."~".$distro.$opts{'fv'};
	my $chlog = <<CHLOG;
trie-tools ($chver) $distro; urgency=low

  * Automatic build - see changelog via: svn log http://visl.sdu.dk/svn/visl/tools/trie-tools/

 -- $opts{e}  $date
CHLOG

	`cp -al 'trie-tools-$version' 'trie-tools-$chver'`;
	unlink "trie-tools-$chver/debian/changelog";
	open FILE, ">trie-tools-$chver/debian/changelog" or die "Could not write to debian/changelog: $!\n";
	print FILE $chlog;
	close FILE;
	print `dpkg-source '-DMaintainer=$opts{m}' '-DUploaders=$opts{e}' -b 'trie-tools-$chver'`;
	chdir "trie-tools-$chver";
	print `dpkg-genchanges -S -sa '-m$opts{m}' '-e$opts{e}' > '../trie-tools_$chver\_source.changes'`;
	chdir '..';
	print `debsign 'trie-tools_$chver\_source.changes'`;
}

chdir "/tmp";
