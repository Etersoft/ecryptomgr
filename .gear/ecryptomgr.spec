Name: ecryptomgr
Version: 0.1
Release: alt1

Summary: Crypto provider installer

License: Public domain
Group: File tools

Source: %name-%version.tar

BuildArch: noarch

%define sdir %_datadir/%name

%description
Crypto provider installer.

run
 $ crypto-install in a dir with downloaded crypto provider distribute.

Supported:
 * CryptoPro 4/5 64/32 bit
 * ViPNet CSP 4.2/4.4 64/32 bit

%prep
%setup

%build
subst "s|^SDIR=.*|SDIR=%sdir|" ecryptomgr.sh

%install
mkdir -p %buildroot%sdir/
install -D ecryptomgr.sh %buildroot%_bindir/ecryptomgr
for i in clean_* install_* uninstall_* test_* ; do
    install $i %buildroot%sdir/
done

%files
%doc README.md
%_bindir/ecryptomgr
%sdir/

%changelog
* Wed Sep 30 2020 Vitaly Lipatov <lav@altlinux.ru> 0.1-alt1
- initial build for ALT Sisyphus
