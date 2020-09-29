
Common utility:
 $ ecryptomgr install|uninstall|clean|license|status [--devel] [cprocsp|itcs] [32|64|both]

Используйте
 ./install_cryptopro.sh [--devel] 32|64|both
для установки 32-битной, 64-битной версии, или both для установки обеих версий (рекомендуется).

Для удаления:
 ./uninstall_cryptopro.sh 32|64|both

--devel устанавливает средства разработки (devel-пакеты)


TODO:
install.sh вызывает uninstall, если видит, что пакеты уже установлены:
./uninstall.sh: строка 88: lsb-cprocsp-rdr-5.0.11453-5.i686: команда не найдена

TODO itcs both:
change scripts and rename package too

TODO:
Роса:
http://wiki.rosalab.ru/ru/index.php/%D0%98%D0%BD%D1%81%D1%82%D1%80%D1%83%D0%BA%D1%86%D0%B8%D1%8F_%D0%BF%D0%BE_%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B5_%D0%9A%D1%80%D0%B8%D0%BF%D1%82%D0%BE%D0%9F%D1%80%D0%BE
Astra

TODO: --gui

