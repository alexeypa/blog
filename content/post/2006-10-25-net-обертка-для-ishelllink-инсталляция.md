---
author: admin
date: 2006-10-25 22:59:38+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2006/10/25/90
slug: net-обертка-для-ishelllink-инсталляция
title: .NET обертка для IShellLink (инсталляция)
wordpress_id: 90
tags:
- COM
- Программирование
- PowerShell
---

Как и [обещал](http://blog.not-a-kernel-guy.com/2006/10/22/87), выкладываю ссылку на инсталляцию:

  * [ShellLib (x86)](http://blog.not-a-kernel-guy.com/wp-content/uploads/2006/10/ShellLib_x86.msi) - версия для 32-битного Windows XP/2003;

  * [ShellLib (x64)](http://blog.not-a-kernel-guy.com/wp-content/uploads/2006/10/ShellLib_x64.msi) - версия для 64-битного Windows XP/2003. 

Инсталляция не содержит практически никакого пользовательского интерфейса - зачем он там нужен? Деинсталляция – через Add or Remove Programs. Инсталляция создавалась, как не трудно догадаться, с помощью WiX. :-) Исходный код инсталляционного скрипта можно скачать вместе с [обновленными исходниками](http://blog.not-a-kernel-guy.com/wp-content/uploads/2006/10/ShellLib_src.zip).
