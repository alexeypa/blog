---
author: admin
date: 2008-01-10 07:34:16+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2008/01/09/277
slug: разрядность-ключа-image-file-execution-options
title: Разрядность ключа «Image File Execution Options»
wordpress_id: 277
tags:
- 64bit
- Маленькие хитрости
- Отладка
- Windows
---

[Ключ «Image File Execution Options»](http://blogs.msdn.com/junfeng/archive/2004/04/28/121871.aspx) знаком, наверное, всем кто вынужден тратить много времени на отладку приложений. В частности, с его помощью можно указать системе всегда запускать определённый процесс под отладчиком. В этом же ключе [утилита gflags.exe](http://technet2.microsoft.com/windowsserver/en/library/b6af1963-3b75-42f2-860f-aff9354aefde1033.mspx?mfr=true) сохраняет выбранные отладочные опции и т.д. За подробностями рекомендую обратиться в Google, там есть много полезного. 

Я же хочу остановиться на другой особенности этого ключа. На 64-х битной системе, он, как и большинство других ключей в ветке «HKLM\SOFTWARE», существует в двух экземплярах. 64-х битные приложения используют « HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options», а 32-х битные - «HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options». Пока что всё просто и очевидно. Сложности начинаются, когда целевое приложение написано на .NET и скомпилировано как AnyCPU сборка. Такой .exe запускается как 32-х битный процесс на 32-х разрядной машине и как 64-х битный - на 64-х разрядной системе. Если вы попробуете запустить это приложение под отладчиком, воспользовавшись 64-х битной версией ключа «Image File Execution Options»:

```no-highlight
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\foobar.exe]
"Debugger"="c:\\dbg\\windbg.exe"
```

…то у вас ничего не выйдет. 

Если же создать точно такое же значение в 32-х разрядной части реестра:

```no-highlight
[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\foobar.exe]
"Debugger"="c:\\dbg\\windbg.exe"
```

…то всё заработает как по волшебству. В чём тут дело? Ведь само приложение запускается как 64-х битный процесс?

Все дело в PE заголовке. Если вы помните, [AnyCPU сборки указывают x86 в качестве целевой архитектуры в заголовке выполняемого файла](http://blog.not-a-kernel-guy.com/2007/12/18/272). Значение «Debugger» [читается родительским процессом](http://blogs.msdn.com/oldnewthing/archive/2007/07/02/3652873.aspx), который проверяет PE заголовок запускаемого провеса, чтобы определить какой из ключей «Image File Execution Options» использовать - 32-х или 64-х битный. И в случае AnyCPU эта проверка даёт сбой.

Однако на этом сложности не заканчиваются. Если вы используете другие разрешенные значения, например «GlobalFlags», или пользуетесь утилитой gflags.exe, что, в общем-то, одно и то же, то для AnyCPU сборок вы должны создавать их в 64-х битной версии ключа «Image File Execution Options». В отличие от «Debugger», «GlobalFlags» и другие значения читаются самим процессом, а поскольку процесс 64-х битный, то и читаться они будут из 64-х битного ключа. 

Полная схема «участников процесса» выглядит вот так:

  1. Ядро (в недрах NtCreateUserProcess) проверяет наличие ключа «Image File Execution Options» для данного запускаемого файла. При этом проверяется поле «machine» в PE заголовке. В зависимости от результатов проверки открывается 32-х битный или 64-х битный ключ; 

  2. Родительский получает описатель открытого ключа из NtCreateUserProcess и если значение «Debugger» присутствует, то в командную строку добавляется команда для вызова отладчика и NtCreateUserProcess вызывается по новой. На этом этапе разрядность проверяемого ключа «Image File Execution Options» по-прежнему определяется полем «machine» в PE заголовке; 

  3. Вновь созданный процесс заново открывает ключ «Image File Execution Options» и читает все остальные значения. На этот раз разрядность ключа определяется настоящей разрядностью процесса. 

В общем, вот так все непросто.
