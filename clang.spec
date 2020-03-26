Name:       kewb-clang%{clang_tag}
Version:    %{clang_version}
Release:    %{clang_rpm_release}

Summary:    Custom Clang %{clang_version} build by KEWB
License:    GPL
Group:      Development Tools
Vendor:     KEWB Enterprises

AutoReq:        0
ExclusiveArch:  %{product_arch}
ExclusiveOS:    %{product_os}

%define debug_package %{nil}
%define __strip /bin/true

%description
This package provides a customized, modular installation of Clang %{clang_version}.


%prep


%build


%pre


%install

rm -rf $RPM_BUILD_ROOT

BR_DIR=%{build_root_dir}
IREL_DIR=%{clang_install_reldir}
IPREFIX=%{clang_install_prefix}
ISREL_DIR=%{clang_install_scripts_reldir}
ISPREFIX=%{clang_install_scripts_prefix}
VERSION=%{clang_version}
TAG=%{clang_tag}

mkdir -p $RPM_BUILD_ROOT/$ISREL_DIR
mkdir -p $RPM_BUILD_ROOT/$IREL_DIR

cp -pv  $BR_DIR/$ISREL_DIR/setenv-for-clang$TAG.sh            $RPM_BUILD_ROOT/$ISREL_DIR
cp -pv  $BR_DIR/$ISREL_DIR/restore-default-paths-clang$TAG.sh $RPM_BUILD_ROOT/$ISREL_DIR
cp -rpv $BR_DIR/$IREL_DIR/*                                   $RPM_BUILD_ROOT/$IREL_DIR

cd $RPM_BUILD_ROOT/$ISREL_DIR

ln -s -v $IPREFIX/bin/clang   clang$TAG
ln -s -v $IPREFIX/bin/clang++ clang++$TAG

touch -h -r setenv-for-clang$TAG.sh clang$TAG
touch -h -r setenv-for-clang$TAG.sh clang++$TAG
touch -h -r setenv-for-clang$TAG.sh $RPM_BUILD_ROOT/$IREL_DIR

exit 0


%post

exit 0


%preun

exit 0


%postun
##- Note that %postun also gets called when upgrading.  We have to check the
##  argument passed to %postun (the number of copies of the RPM installed after
##  this is run) to determine whether this is an upgrade, or a removal.  "0"
##  means removal, and >0 means upgrade

if [ $1 = "0" ]; then
    VERSION=%{clang_version}
    TAG=%{clang_tag}
fi

exit 0

%verifyscript

%clean

rm -rf $RPM_BUILD_ROOT
exit 0


%files

%ifos freebsd
%attr(-,root,wheel) %{clang_install_scripts_reldir}/setenv-for-clang%{clang_tag}.sh
%attr(-,root,wheel) %{clang_install_scripts_reldir}/restore-default-paths-clang%{clang_tag}.sh
%attr(-,root,wheel) %{clang_install_scripts_reldir}/clang%{clang_tag}
%attr(-,root,wheel) %{clang_install_scripts_reldir}/clang++%{clang_tag}
%attr(-,root,wheel) %{clang_install_prefix}
%else
%attr(-,root,root) %{clang_install_scripts_reldir}/setenv-for-clang%{clang_tag}.sh
%attr(-,root,root) %{clang_install_scripts_reldir}/restore-default-paths-clang%{clang_tag}.sh
%attr(-,root,root) %{clang_install_scripts_reldir}/clang%{clang_tag}
%attr(-,root,root) %{clang_install_scripts_reldir}/clang++%{clang_tag}
%attr(-,root,root) %{clang_install_prefix}
%endif

%config

%doc

%changelog
