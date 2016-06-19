---
author: admin
date: 2008-03-14 04:41:33+00:00
link: http://blog.not-a-kernel-guy.com/2008/03/13/297
slug: как-process-explorer-подменяет-task-manager
title: Как Process Explorer подменяет Task Manager
wordpress_id: 297
tags:
- Инструменты
- Маленькие хитрости
- Process Explorer
- Sysinternals
- Task Manager
---

А знаете, как [Process Explorer](http://technet.microsoft.com/en-us/sysinternals/bb896653.aspx) подменяет собой стандартный Task Manager?

![Process Explorer: Replace Task Manager.](/2008/03/procexp_1.png)

Оказывается всё очень просто и банально. Он устанавливает себя в качестве отладчика для taskmgr.exe!

![Process Explorer is set as a ](/2008/03/procexp_2.png)

Преимущества такого метода перехвата:

  1. Подмена происходит в недрах CreateProcess. Неважно кто и как запускает taskmgr.exe, всегда будет запущен Process Explorer;

  2. Не нужно возиться Windows File Protection (WPF), пытаясь подменить исполняемый файл Task Manager'а в %windir%\system32.

Недостатки:

  1. Подмена происходит вне зависимости от реального местонахождения taskmgr.exe. Это может быть и не Task Manager вовсе, просто имя совпало. Все равно вместо него будет запущен Process Explorer;

  2. Имя запускаемого файла "taskmgr.exe" передается в командную строку подменяющего процесса. Т.е. так просто напрямую заменить notepad.exe на другой редактор не получится.

![](/2008/03/procexp_3.png)

Но вообще-то очень остроумно сделано.
