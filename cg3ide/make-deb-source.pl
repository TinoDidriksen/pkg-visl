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
	'm' => 'Tino Didriksen <mail@tinodidriksen.com>',
	'e' => 'Tino Didriksen <mail@tinodidriksen.com>',
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

print `svn export http://visl.sdu.dk/svn/visl/tools/cg3ide/src/version.hpp`;
my $major = 0;
my $minor = 0;
my $patch = 0;
my $revision = `svn log -q -l 1 http://visl.sdu.dk/svn/visl/tools/cg3ide/ | egrep -o '^r[0-9]+' | egrep -o '[0-9]+'` + 0;
{
	local $/ = undef;
	open FILE, 'version.hpp' or die "Could not open version.hpp: $!\n";
	my $data = <FILE>;
	($major,$minor,$patch) = ($data =~ m@CG3IDE_VERSION_MAJOR = (\d+);.*?CG3IDE_VERSION_MINOR = (\d+);.*?CG3IDE_VERSION_PATCH = (\d+);@s);
	close FILE;
}

my $version = "$major.$minor.$patch.$revision";
my $date = `date -u -R`;

print `svn export http://visl.sdu.dk/svn/visl/tools/cg3ide/ 'cg3ide-$version'`;
`find 'cg3ide-$version' ! -type d | LC_ALL=C sort > orig.lst`;
print `tar -jcvf 'cg3ide_$version.orig.tar.bz2' -T orig.lst`;
print `svn export http://visl.sdu.dk/svn/visl/opensource/packaging/cg3ide/debian/ 'cg3ide-$version/debian/'`;

foreach my $distro (keys %distros) {
	my $chver = $version.'-';
	if ($distros{$distro} eq 'ubuntu') {
		$chver .= "0ubuntu";
	}
	$chver .= $opts{'dv'}."~".$distro.$opts{'fv'};
	my $chlog = <<CHLOG;
cg3ide ($chver) $distro; urgency=low

  * Automatic build - see changelog via: svn log http://visl.sdu.dk/svn/visl/tools/cg3ide/

 -- $opts{e}  $date
CHLOG

	`cp -al 'cg3ide-$version' 'cg3ide-$chver'`;
	unlink "cg3ide-$chver/debian/changelog";
	open FILE, ">cg3ide-$chver/debian/changelog" or die "Could not write to debian/changelog: $!\n";
	print FILE $chlog;
	close FILE;
	print `dpkg-source '-DMaintainer=$opts{m}' '-DUploaders=$opts{e}' -b 'cg3ide-$chver'`;
	chdir "cg3ide-$chver";
	print `dpkg-genchanges -S -sa '-m$opts{m}' '-e$opts{e}' > '../cg3ide_$chver\_source.changes'`;
	chdir '..';
	print `debsign 'cg3ide_$chver\_source.changes'`;
}

chdir "/tmp";
