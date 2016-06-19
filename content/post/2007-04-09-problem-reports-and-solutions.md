---
author: admin
comments: true
date: 2007-04-09 04:03:04+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2007/04/08/170
slug: problem-reports-and-solutions
title: Как запустить отладчик при аварийном завершении приложения в Vista.
wordpress_id: 170
categories:
- itblogs
tags:
- Отладка
---

По умолчанию служба "Problem reports and solutions" в Vista настроена так, что при аварийном завершении приложения у пользователя есть выбор из двух вариантов: посылать или не посылать отчет на сервер Microsoft. Это довольно логичный выбор в случае если за компьютером сидит "средний" пользователь, которого негоже пугать отладчиком. Однако отнимать у разработчика возможность загрузить любимый отладчик нехорошо. :-) Чтобы исправить ситуацию достаточно просто выключить Problem reporting.

Выберите Problem Reports and Solutions в Control Panel/System and Maintenance:

[![Problem reports and solutions.](http://blog.not-a-kernel-guy.com/wp-content/uploads/2007/04/problem_reports_and_solutions.thumbnail.png)](http://blog.not-a-kernel-guy.com/wp-content/uploads/2007/04/problem_reports_and_solutions.png)

Выберите Change settings в появившемся окне:

[![Settings.](http://blog.not-a-kernel-guy.com/wp-content/uploads/2007/04/problem_reports_and_solutions_settings.thumbnail.png)](http://blog.not-a-kernel-guy.com/wp-content/uploads/2007/04/problem_reports_and_solutions_settings.png)

Затем - Advanced settings:

[![Advanced settings.](http://blog.not-a-kernel-guy.com/wp-content/uploads/2007/04/problem_reports_and_solutions_advanced.thumbnail.png)](http://blog.not-a-kernel-guy.com/wp-content/uploads/2007/04/problem_reports_and_solutions_advanced.png)

И наконец выберите Off под "For my programs, problem reporting is": 

[![Problem reportings is off.](http://blog.not-a-kernel-guy.com/wp-content/uploads/2007/04/problem_reports_and_solutions_off.thumbnail.png)](http://blog.not-a-kernel-guy.com/wp-content/uploads/2007/04/problem_reports_and_solutions_off.png)

Теперь при аварийном завершении приложения система будет показывать вот такое окно:

![A debugger pops up on an application crash.](http://blog.not-a-kernel-guy.com/wp-content/uploads/2007/04/problem_reports_and_solutions_debug.png)

Готово.
