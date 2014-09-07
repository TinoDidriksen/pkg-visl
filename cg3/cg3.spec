Name: cg3
Version: 0.9.8.10063
Release: 1%{?dist}
Summary: Tools for using the 3rd edition of Constraint Grammar (CG-3)
Group: Development/Tools
License: GPL-3.0+
URL: http://visl.sdu.dk/cg3.html
Source0: %{name}_%{version}.orig.tar.bz2
Provides: vislcg3 = %{version}-%{release}

BuildRequires: gcc-c++
%if 0%{?el6}
BuildRequires: wget
BuildRequires: cmake28 >= 2.8.9
%else
BuildRequires: cmake >= 2.8.9
BuildRequires: boost-devel >= 1.48.0
%endif
BuildRequires: libicu-devel >= 4.2
BuildRequires: pkgconfig

%description
Constraint Grammar compiler and applicator for the 3rd edition of CG
that is developed and maintained by VISL SDU and GrammarSoft ApS.

CG-3 can be used for disambiguation of morphology, syntax, semantics, etc;
dependency markup, target language lemma choice for MT, QA systems, and
much more. The core idea is that you choose what to do based on the whole
available context, as opposed to n-grams.

See http://visl.sdu.dk/cg3.html for more documentation

%package -n libcg3-0
Summary: Runtime for CG-3
Group: Development/Libraries
Provides: libcg3 = %{version}-%{release}

%description -n libcg3-0
Runtime library for applications using the CG-3 API.

It is recommended to instrument the CLI tools instead of using this API.

See http://visl.sdu.dk/cg3.html for more documentation


%package -n libcg3-devel
Summary: Headers and static library to develop using the CG-3 library
Group: Development/Libraries
Requires: libcg3-0 = %{version}-%{release}

%description -n libcg3-devel
Development files to use the CG-3 API.

It is recommended to instrument the CLI tools instead of using this API.

See http://visl.sdu.dk/cg3.html for more documentation


%prep
%setup -q -n %{name}-%{version}

%build
%if 0%{?el6}
./get-boost.sh
%cmake28 .
%else
%if 0%{?suse_version}
%cmake
%else
%cmake .
%endif
%endif
make %{?_smp_mflags}

%install
%if 0%{?suse_version}
%cmake_install
%else
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
%endif
ln -s vislcg3 %{buildroot}%{_bindir}/cg3
ln -s vislcg3.1.gz %{buildroot}%{_datadir}/man/man1/cg3.1.gz

%check
make test

%files
%doc AUTHORS ChangeLog COPYING README TODO
%{_bindir}/*
%{_datadir}/man/man1/*
%{_datadir}/emacs/site-lisp/*

%files -n libcg3-0
%{_libdir}/*.so.*
%{_libdir}/cg3

%files -n libcg3-devel
%{_includedir}/*
%{_libdir}/pkgconfig/*
%{_libdir}/*.a*
%{_libdir}/*.so

%post -n libcg3-0 -p /sbin/ldconfig

%postun -n libcg3-0 -p /sbin/ldconfig

%changelog
* Fri Sep 05 2014 Tino Didriksen <mail@tinodidriksen.com> 0.9.8.10063-1
- Initial version of the package
