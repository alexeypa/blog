---
author: admin
date: 2007-08-28T23:24:31-07:00
aliases:
- /2007/08/28/231
title: Как собрать DParser for Python с помощью Visual C++ 2005?
slug: 231
tags:
- Инструменты
- Win32.Utf8
---

Существует два способа собрать DParser for Python под Windows:

  1. Легкий – воспользоваться GCC из MinGW и немного пошаманить;

  2. Интересный – попытаться сделать тоже самое с помощью Visual C++ 2005. 

Естественно, что я выбрал второй вариант. :-) 

_(На самом деле причина довольно прозаична – не хотелось собирать один проект двумя разными компиляторами)._

<!--more-->Исходные данные:

  * [Python v2.5.1](http://www.python.org). Я пробовал x86 и x64 варианты. Версия для Itanium должна работать точно так же;

  * [DParser v1.15](http://dparser.sourceforge.net);

  * [Boost.Build v2](http://www.boost.org/tools/build/v2/index.html). Любая другая система сборки проектов тоже подойдёт;

  * Visual C++ 2005.

Последовательность действий:

  1. Распаковываем DParser куда-нибудь, скажем "C:\temp\D".

  2. Применяем [патч](https://gist.github.com/alexeypa/578d7263145d46018db8e9a290b92499), который в добавляет недостающие (из-за отсутствующих заголовков) объявления и правит кое-где код.

```no-highlight
pushd C:\\temp
patch -Np1 -d D < dparser-1.15.diff
```

Кроме правки кода, патч добавляет в несколько новых файлов:

    * "Jamfile.v2" и "Jamroot" – скрипты для сборки DParser с помошью Boost.Build v2;

    * "python\setup_win32.py" – Windows версия скрипта для сборки DParser for Python;

    * "python\setup_win32.cmd" – обёртка для setup_win32.py, нужная главным образом для внедрения манифеста в собранную .DLL.

  3. Компилируем DParser:

```no-highlight
cd D
bjam free
```

Для amd64:

```no-highlight
cd D
bjam free architecture=x86 address-model=64
```

Для Itanium:

```no-highlight
cd D
bjam free architecture=ia64
```

При этом собранные библиотеки будут скопированы в “C:\temp\D\dist”.

  4. Запускаем “Visual Studio 2005 Command Prompt” (либо “Visual Studio 2005 x64 Cross Tools Command Prompt”, либо “Visual Studio 2005 Itanium Cross Tools Command Prompt”) под учётной записью администратора (под любым пользователем, имеющим доступ на запись в каталог, где установлен Python).

  5. Если вы компилируете 32-х битную версию, то дополнительно следует поправить проверку на совместимость версий компилятора в “C:\Python25\Lib\distutils\msvccompiler.py”. Для этого нужно применить ещё один [патч](https://gist.github.com/alexeypa/058d81c20b4dbb84b98f263d04c17c2e):

```no-highlight
pushd C:\\Python25\\Lib\\distutils
patch msvccompiler.py msvccompiler.py.diff
popd
```

Этот шаг не обязателен, если вы собираете версию для amd64 или ia64.

  6. Cобираем и устанавливаем DParser for Python:

```no-highlight
cd python
setup_win32.cmd
```

  7. И наконец, проверяем что у нас получилось:

```no-highlight
python
import dparser
print dparser
```

![DParser has been installed successfully.](/2007/08/dparser_test.png)

Готово.
