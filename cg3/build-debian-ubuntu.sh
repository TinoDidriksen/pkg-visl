#!/bin/bash

PROGNAME=cg3

./make-deb-source.pl -m 'Apertium Automaton <apertium-packaging@lists.sourceforge.net>' -e 'Apertium Automaton <apertium-packaging@lists.sourceforge.net>'

rm -fv /var/cache/pbuilder/result/*
mkdir -p /home/apertium/public_html/apt/logs/$PROGNAME/

cd /tmp/autopkg.*
for DISTRO in wheezy jessie sid precise saucy trusty utopic
do
	for ARCH in i386 amd64
	do
		echo "Updating $DISTRO for $ARCH"
		cowbuilder --update --no-cowdancer-update --basepath /var/cache/pbuilder/base-$DISTRO-$ARCH.cow/ >/home/apertium/public_html/apt/logs/$PROGNAME/$DISTRO-$ARCH.log 2>&1
		echo "Building $DISTRO for $ARCH"
		cowbuilder --build *$DISTRO*.dsc --basepath /var/cache/pbuilder/base-$DISTRO-$ARCH.cow/ >>/home/apertium/public_html/apt/logs/$PROGNAME/$DISTRO-$ARCH.log 2>&1 &
	done
done

for job in `jobs -p`
do
	echo "Waiting for $job"
	wait $job
done

rm -f /home/apertium/public_html/apt/logs/$PROGNAME/reprepro.log
for DISTRO in wheezy jessie sid precise saucy trusty utopic
do
	echo "reprepro $DISTRO" >> /home/apertium/public_html/apt/logs/$PROGNAME/reprepro.log
	reprepro -b /home/apertium/public_html/apt/nightly/ includedeb $DISTRO /var/cache/pbuilder/result/*$DISTRO*.deb 2>&1 | tee -a /home/apertium/public_html/apt/logs/$PROGNAME/reprepro.log
done

chown -R apertium:apertium /home/apertium/public_html/apt
