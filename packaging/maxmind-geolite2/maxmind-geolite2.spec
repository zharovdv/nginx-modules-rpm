Name:           maxmind-geolite2
Version:        %{?geolite2_version}%{!?geolite2_version:0}
Release:        %{?geolite2_release}%{!?geolite2_release:1}%{?dist}
Summary:        MaxMind GeoLite2 geolocation databases
License:        CC-BY-SA-4.0 AND LicenseRef-MaxMind-GeoLite2-EULA
URL:            https://dev.maxmind.com/geoip/geolite2-free-geolocation-data/
BuildArch:      noarch
Source0:        GeoLite2-Country.mmdb
Source1:        GeoLite2-City.mmdb
Source2:        GeoLite2-ASN.mmdb
Source3:        GEOLITE2-LICENSE.txt

Requires:       maxmind-geolite2-country = %{country_version}-%{country_release}%{?dist}
Requires:       maxmind-geolite2-city = %{city_version}-%{city_release}%{?dist}
Requires:       maxmind-geolite2-asn = %{asn_version}-%{asn_release}%{?dist}

%description
Metapackage that installs the MaxMind GeoLite2 Country, City and ASN databases.

%package country
Summary:        MaxMind GeoLite2 Country database
Version:        %{country_version}
Release:        %{country_release}%{?dist}
Provides:       geolite2-country-data = %{country_version}-%{country_release}
Conflicts:      geolite2-country

%description country
Free IP geolocation database containing country-level data, created by MaxMind.

%package city
Summary:        MaxMind GeoLite2 City database
Version:        %{city_version}
Release:        %{city_release}%{?dist}
Provides:       geolite2-city-data = %{city_version}-%{city_release}
Conflicts:      geolite2-city

%description city
Free IP geolocation database containing city-level data, created by MaxMind.

%package asn
Summary:        MaxMind GeoLite2 ASN database
Version:        %{asn_version}
Release:        %{asn_release}%{?dist}
Provides:       geolite2-asn-data = %{asn_version}-%{asn_release}
Conflicts:      geolite2-asn

%description asn
Free IP geolocation database containing autonomous-system data, created by MaxMind.

%prep

%build

%install
install -D -m 0644 %{SOURCE0} %{buildroot}%{_datadir}/GeoIP/GeoLite2-Country.mmdb
install -D -m 0644 %{SOURCE1} %{buildroot}%{_datadir}/GeoIP/GeoLite2-City.mmdb
install -D -m 0644 %{SOURCE2} %{buildroot}%{_datadir}/GeoIP/GeoLite2-ASN.mmdb
install -D -m 0644 %{SOURCE3} %{buildroot}%{_licensedir}/%{name}/GEOLITE2-LICENSE.txt

%files
%license %{_licensedir}/%{name}/GEOLITE2-LICENSE.txt

%files country
%license %{_licensedir}/%{name}/GEOLITE2-LICENSE.txt
%{_datadir}/GeoIP/GeoLite2-Country.mmdb

%files city
%license %{_licensedir}/%{name}/GEOLITE2-LICENSE.txt
%{_datadir}/GeoIP/GeoLite2-City.mmdb

%files asn
%license %{_licensedir}/%{name}/GEOLITE2-LICENSE.txt
%{_datadir}/GeoIP/GeoLite2-ASN.mmdb

%changelog
* Thu Jan 01 1970 nginx-modules-rpm project <gandalf@sinnfein.ru> - 0-1
- Package the GeoLite2 Country, City and ASN databases
