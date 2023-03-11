Name: ecryptomgr
Version: 0.9.3
Release: alt1

Summary: Crypto provider installer

License: Public domain
Group: File tools
Url: https://github.com/Etersoft/ecryptomgr

Source: %name-%version.tar

BuildArch: noarch

Requires: eepm >= 3.28.8

%define sdir %_datadir/%name

%description
Crypto provider installer.
Part of CRYPTO@Etersoft project.

Example:
 $ ecryptomgr install cryptopro

Supported:
 * CryptoPro 4/5 64/32 bit
 * ViPNet CSP 4.2/4.4 64/32 bit
 * ruToken 64/32 bit
 * Jacarta 64/32 bit
 * CryptoPro CAdES 64/32 bit

%prep
%setup

%build
subst "s|^SDIR=.*|SDIR=%sdir|" ecryptomgr.sh

%install
mkdir -p %buildroot%sdir/
install -D ecryptomgr.sh %buildroot%_bindir/ecryptomgr
for i in clean_* install_* uninstall_* test_* functions.sh ; do
    install $i %buildroot%sdir/
done

%files
%doc README.md
%_bindir/ecryptomgr
%sdir/

%changelog
* Wed Apr 27 2022 Vitaly Lipatov <lav@altlinux.ru> 0.9.3-alt1
- fix libjcpkcs11 name
- fix typo in a description
- ecryptomgr.sh: remove cprocsp as default

* Tue Apr 26 2022 Vitaly Lipatov <lav@altlinux.ru> 0.9.2-alt1
- add separate install for pcsc support
- add --gui-install for use install-gui.sh in CryptoPro install process
- install_cryptopro.sh: reinstall lsb-core with --auto
- install_cryptopro.sh: install 32 bit packages by list of installed 64 bit packages
- install_cryptopro.sh: fix i586 install

* Mon Apr 11 2022 Vitaly Lipatov <lav@altlinux.ru> 0.9.1-alt1
- install_cryptopro.sh: check libjcpkcs11 instead of jcPKCS11-2
- install_crypropro.sh: add libpng12 install for GUI

* Wed Apr 06 2022 Vitaly Lipatov <lav@altlinux.ru> 0.9.0-alt1
- use eget 5.3 and eepm 3.16
- replace distro_info with epm print info
- install_cryptopro.sh: install libidn.so.11
- install_cades.sh: fix downloading tar and install packages (ALT bug 42014)
- use common functions from functions.sh, enable SUDO support
- install_jacarta.sh: install libjcpkcs11 (ALT bug 42015)

* Mon Dec 13 2021 Vitaly Lipatov <lav@altlinux.ru> 0.8.4-alt1
- install_cryptopro.sh: fix install i586-lsb-core, fix support for Sisyphus and p10

* Wed Aug 04 2021 Vitaly Lipatov <lav@altlinux.ru> 0.8.3-alt1
- ecryptomgr.sh: allow args in any order
- use epm --script to (un)install cades

* Tue Oct 20 2020 Vitaly Lipatov <lav@altlinux.ru> 0.8.2-alt1
- add user's Download dir checking for a tarball
- fix install order cprocsp-rdr-pcsc
- install_cryptopro.sh: remove all lock files from /var/opt/cprocsp/tmp/ before install

* Fri Oct 09 2020 Vitaly Lipatov <lav@altlinux.ru> 0.8.1-alt1
- improve README.md
- fix direct script call

* Fri Oct 09 2020 Vitaly Lipatov <lav@altlinux.ru> 0.8-alt1
- install_cryptopro.sh/install_itcs.sh: don't run if some packages already installed
- install_cryptopro.sh: add package integrity checking
- install_cryptopro.sh: cleanup process
- add tests for cryptopro and itcs integrity

* Fri Oct 09 2020 Vitaly Lipatov <lav@altlinux.ru> 0.7-alt1
- install_cryptopro.sh: fix distr dir checking
- add cadesplugin install support

* Thu Oct 08 2020 Vitaly Lipatov <lav@altlinux.ru> 0.6-alt1
- install_itcs.sh: add libqt4 install (for qt = version provide)
- install*: add /opt/distr support
- install_rutoken.sh: install libpcsclite
- uinstall_cryptopro.sh: remove all cprocsp packages if have not CryptoPro uninstall.sh
- install_cryptopro.sh: install jacarta/rutoken support only if their packages are already installed

* Sat Oct 03 2020 Vitaly Lipatov <lav@altlinux.ru> 0.5-alt1
- add test_jacarta.sh
- newt52 provides whiptail for unused install-gui.sh
- add --nogui option, allow any position for --devel

* Fri Oct 02 2020 Vitaly Lipatov <lav@altlinux.ru> 0.4-alt1
- update README.md
- separate rutoken control
- add JaCarta support
- install_itcs.sh: rewrite to improve both support

* Thu Oct 01 2020 Vitaly Lipatov <lav@altlinux.ru> 0.3-alt1
- improve description
- ecryptomgr.sh: add arch detection

* Thu Oct 01 2020 Vitaly Lipatov <lav@altlinux.ru> 0.2-alt1
- add license check support
- unstall_cryptopro.sh: test and fix
- fix install/uninstall CryptoPro on i586
- install_itcs.sh: install libqt4-gui for 32 over 64

* Wed Sep 30 2020 Vitaly Lipatov <lav@altlinux.ru> 0.1-alt1
- initial build for ALT Sisyphus
