
## Crypto Manager — управление криптосредствами в Linux.

Входит в продукт CRYPTO@Etersoft.

Поддерживаются:
* CryptoPro
* ViPNet CSP

Текущая версия разработана только для ОС ALT.

По проблемам создавайте issue или pull requests в репозитории на github.

## Примеры использования

Установите в систему пакет ecryptomgr:
 # epm install ecryptomgr

### CryptoPro

В каталоге со скаченным архивов, чтобы установить 64-битную версию
 $ ecryptomgr install cprocsp 64

### VipNet CSP

В каталоге с rpm-пакетами, чтобы установить 32-битную версию
 $ ecryptomgr install itcs 32


## Общий формат запуска
 $ ecryptomgr install|uninstall|clean|license|status [--devel] [cprocsp|itcs] [32|64|both]

Commands:
* install — install crypto provider
* remove — uninstall crypto provider
* clean → remove old files after uninstall (wipe all related data)
* license — check license status
* status — check if crypto provider is installed
* test — run test (in development)

Crypto providers:
* cprocsp — CryptoPro
* itcs — ViPNet CSP
(в планах сделать автоопределение по файлам в текущем каталоге)

Options:
* --devel — устанавливает средства разработки (devel-пакеты)

Arch (autodetected if omit)
* 32 - i586 packages (does not matter you have 32 or 64 bit OS)
* 64 - x86_64 packages
* both - install both 32 and 64 bit (not supported yet for ViPNet CSP)

Для установки криптопровайдера загрузите предлагаемые поставщиком файлы и запустите в каталоге с ними команду ecryptmgr с нужными параметрами.

Examples:
 $ ecryptomgr install cprocsp
 $ ecryptomgr install cprocsp both
 $ ecryptomgr install itcs 32

Для самой актуальной справки смотрите
 $ ecryptomgr --help

### Низкоуровневые средства

Можно непосредственно использовать скрипты

 $ ./install_cryptopro.sh [--devel] 32|64|both
для установки 32-битной, 64-битной версии, или both для установки обеих версий (рекомендуется).

Для удаления:
 $ ./uninstall_cryptopro.sh 32|64|both


# TODO

копировать install.sh в систпму при установке или отказаться от него, чтобы удаление не требовало дистрибутива.

TODO:
install.sh вызывает uninstall, если видит, что пакеты уже установлены:
./uninstall.sh: строка 88: lsb-cprocsp-rdr-5.0.11453-5.i686: команда не найдена

TODO itcs both:
change scripts and rename package too

TODO:
Роса:
http://wiki.rosalab.ru/ru/index.php/%D0%98%D0%BD%D1%81%D1%82%D1%80%D1%83%D0%BA%D1%86%D0%B8%D1%8F_%D0%BF%D0%BE_%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B5_%D0%9A%D1%80%D0%B8%D0%BF%D1%82%D0%BE%D0%9F%D1%80%D0%BE
Astra

TODO: --gui (сейчас по умолчанию)

