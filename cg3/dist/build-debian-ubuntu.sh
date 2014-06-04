#!/bin/bash

./dist-debian-ubuntu.pl -m 'Apertium Automaton <apertium-packaging@lists.sourceforge.net>' -e 'Apertium Automaton <apertium-packaging@lists.sourceforge.net>'

rm -fv /var/cache/pbuilder/result/*

cd /tmp/autopkg.*
for DISTRO in wheezy jessie sid precise saucy trusty utopic
do
	for ARCH in i386 amd64
	do
		echo "Updating $DISTRO for $ARCH"
		cowbuilder --update --basepath /var/cache/pbuilder/base-$DISTRO-$ARCH.cow/
		echo "Building $DISTRO for $ARCH"
		cowbuilder --build *$DISTRO*.dsc --basepath /var/cache/pbuilder/base-$DISTRO-$ARCH.cow/
	done
done

for DISTRO in wheezy jessie sid precise saucy trusty utopic
do
	reprepro -b /home/apertium/public_html/apt/nightly/ includedeb $DISTRO /var/cache/pbuilder/result/*$DISTRO*.deb
done

chown -R apertium:apertium /home/apertium/public_html/apt
