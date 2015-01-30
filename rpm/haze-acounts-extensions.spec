Name:       haze-acounts-extensions

Summary:    Extensions plugins for Telepathy Haze library
Version:    0.2.0
Release:    1
Group:      System/Application
License:    Other
Source0:    %{name}-%{version}.tar.gz
Requires:   libpurple
Requires:   telepathy-haze
Requires:   jolla-settings-accounts >= 0.2.27
BuildArch:  noarch

%description
Extensions plugins for Telepathy Haze library

%prep
%setup -q

# >> setup
# << setup

%build
# >> build pre
# << build pre

# >> build post
# << build post

%install
rm -rf %{buildroot}

mkdir -p %{buildroot}%{_datadir}/haze-accounts-extensions/icons

mkdir -p %{buildroot}%{_datadir}/accounts
mkdir -p %{buildroot}%{_datadir}/accounts/providers
mkdir -p %{buildroot}%{_datadir}/accounts/services
mkdir -p %{buildroot}%{_datadir}/accounts/ui

install -m 644 icons/* %{buildroot}%{_datadir}/haze-accounts-extensions/icons

install -m 644 icq/icq.provider %{buildroot}%{_datadir}/accounts/providers
install -m 644 icq/icq.service %{buildroot}%{_datadir}/accounts/services
install -m 644 icq/icq.qml %{buildroot}%{_datadir}/accounts/ui
install -m 644 icq/icq-settings.qml %{buildroot}%{_datadir}/accounts/ui
install -m 644 icq/icq-update.qml %{buildroot}%{_datadir}/accounts/ui
install -m 644 icq/ICQCommon.qml %{buildroot}%{_datadir}/accounts/ui
install -m 644 icq/ICQSettingsDisplay.qml %{buildroot}%{_datadir}/accounts/ui

# >> install pre
# << install pre

# >> install post
# << install post

%files
%defattr(-,root,root,-)
%{_datadir}/accounts/providers/*
%{_datadir}/accounts/services/*
%{_datadir}/accounts/ui/*
%{_datadir}/haze-accounts-extensions/icons/*

%clean
rm -rf %{buildroot}