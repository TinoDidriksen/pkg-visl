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

print `svn export http://visl.sdu.dk/svn/visl/tools/vislcg3/trunk/src/version.hpp`;
my $major = 0;
my $minor = 0;
my $patch = 0;
my $logline = `svn log -q -l 1 http://visl.sdu.dk/svn/visl/tools/vislcg3/trunk/ | grep '^r'`;
my ($revision,$srcdate) = ($logline =~ m@^r(\d+) \| [^|]+\| ([^(]+)@);
{
	local $/ = undef;
	open FILE, 'version.hpp' or die "Could not open version.hpp: $!\n";
	my $data = <FILE>;
	($major,$minor,$patch) = ($data =~ m@CG3_VERSION_MAJOR = (\d+);.*?CG3_VERSION_MINOR = (\d+);.*?CG3_VERSION_PATCH = (\d+);@s);
	close FILE;
}

my $version = "$major.$minor.$patch.$revision";
my $date = `date -u -R`;

print `svn export http://visl.sdu.dk/svn/visl/tools/vislcg3/trunk/ 'cg3-$version'`;
`rm -rf 'cg3-$version/win32'`;
`find 'cg3-$version' ! -type d | LC_ALL=C sort > orig.lst`;
print `tar --no-acls --no-xattrs '--mtime=$srcdate' -cf 'cg3_$version.orig.tar' -T orig.lst`;
`bzip2 -9c 'cg3_$version.orig.tar' > 'cg3_$version.orig.tar.bz2'`;
print `svn export http://visl.sdu.dk/svn/visl/opensource/packaging/cg3/debian/ 'cg3-$version/debian/'`;

foreach my $distro (keys %distros) {
	my $chver = $version.'-';
	if ($distros{$distro} eq 'ubuntu') {
		$chver .= "0ubuntu";
	}
	$chver .= $opts{'dv'}."~".$distro.$opts{'fv'};
	my $chlog = <<CHLOG;
cg3 ($chver) $distro; urgency=low

  * Automatic build - see changelog via: svn log http://visl.sdu.dk/svn/visl/tools/vislcg3/trunk/

 -- $opts{e}  $date
CHLOG

	`cp -al 'cg3-$version' 'cg3-$chver'`;
	unlink "cg3-$chver/debian/changelog";
	open FILE, ">cg3-$chver/debian/changelog" or die "Could not write to debian/changelog: $!\n";
	print FILE $chlog;
	close FILE;
	print `dpkg-source '-DMaintainer=$opts{m}' '-DUploaders=$opts{e}' -b 'cg3-$chver'`;
	chdir "cg3-$chver";
	print `dpkg-genchanges -S -sa '-m$opts{m}' '-e$opts{e}' > '../cg3_$chver\_source.changes'`;
	chdir '..';
	print `debsign 'cg3_$chver\_source.changes'`;
}
