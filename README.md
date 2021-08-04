TODO status
использовать epm --scripts install
Перейти на общий functions и использовать функцию установки стороннего пакета
внедрить контроль зависимостей

## Crypto Manager — управление криптосредствами в Linux.

Входит в продукт CRYPTO@Etersoft.

Поддерживаются:
* CryptoPro
* ViPNet CSP
* ruToken
* JaCarta
* CAdES Plugin

Текущая версия разработана только для ОС ALT.

Дистрибутив с пакетами для установки сначала ищется в /opt/distr/CryptoPro (/opt/distr/ViPNet), а потом в текущем каталоге.

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

    $ ecryptomgr install|uninstall|clean|license|status [--devel] [--nogui] [cprocsp|itcs|rutoken|jacarta|cades] [32|64|both]

Commands:
* install — install crypto provider
* remove — uninstall crypto provider
* clean — remove old files after uninstall (wipe all related data)
* license — check license status
* status — check if crypto provider is installed
* test — run test (in development)

Crypto providers:
* cprocsp — CryptoPro
* itcs — ViPNet CSP
* rutoken - ruToken
* jacarta - JaCarta
* cades - CryptoPro CAdES Plugin

(в планах сделать автоопределение по файлам в текущем каталоге)

Options:
* --devel — устанавливает средства разработки (devel-пакеты)
* --nogui — не устанавливает графические утилиты

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

### Классы защиты КС1, КС2, КС3
* КС1 — это базовое программное обеспечение СКЗИ (предполагается, что имеем случайного внешнего нарушителя, который может перехватывать информацию в каналах связи; достаточные требования — математическая стойкость, корректности реализации и качество ключей).
* КС2 — состоит из базового СКЗИ класса КС1 совместно с сертифицированным аппаратно-программным модулем доверенной загрузки (АПМДЗ).
* КС3 — состоит из СКЗИ класса КС2 совместно со специализированным программным обеспечением для создания и контроля замкнутой программной среды.

# TODO

TODO: check installed components and print about needed order

копировать uninstall.sh в систему при установке или отказаться от него, чтобы удаление не требовало дистрибутива.

TODO:
отказаться от использования install.sh
install.sh вызывает uninstall, если видит, что пакеты уже установлены:
./uninstall.sh: строка 88: lsb-cprocsp-rdr-5.0.11453-5.i686: команда не найдена

TODO itcs both:
change scripts and rename package too

