---
author: admin
comments: true
date: 2008-03-24 05:46:19+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2008/03/23/299
slug: process-monitor-научился-трассировать-32-х-битный-ст
title: Process Monitor научился трассировать 32-х битный стек на x64.
wordpress_id: 299
categories:
- itblogs
tags:
- Инструменты
- Отладка
- Process Monitor
- Sysinternals
---

Я как-то привык, что Process Monitor не умеет показывать 32-х битный стек события, которое произошло в 32-х разрядном процессе, выполняющемся под Wow64. Вместо этого он показывал только 64-х битный стек, что было абсолютно бесполезно, так как там по определению всегда светится wow64.dll сотоварищи. Однако после подсказки на [Sysinternals Forums](http://forum.sysinternals.com/forum_posts.asp?TID=13227#65748) выяснилось, что начиная с Vista SP1 это уже работает. 

Подтверждаю, действительно работает:

![Process Monitor shows Wow64 symbols.](http://blog.not-a-kernel-guy.com/wp-content/uploads/2008/03/process_monitor_wow64_stack.png)

Конфигурация: 

  * Vista SP1 (6001.18000.amd64fre.longhorn_rtm.080118-1840) 

  * Process Monitor v1.26 

  * Debugging Tools for x64 v6.8.4.0 

Process Monitor использует dbghelp.dll из состава Debugging Tools. Используются символы с [http://msdl.microsoft.com/download/symbols](http://msdl.microsoft.com/download/symbols).

Кстати, показанный порядок вызовов не совсем верный. На самом деле весь 32-х битный код (строки 19-26) должен быть между 13-ой и 14-ой строками. Но тут порядок зависит от того, как его выдают Rtl функции из ntdll.dll, а они, насколько я понимаю, не затрудняются формированием правильного порядка вызовов. Просто сначала трассируется 64-х битный стек, а затем - 32-х битный.
