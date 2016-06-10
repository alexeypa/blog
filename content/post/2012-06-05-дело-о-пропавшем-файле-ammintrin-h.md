---
author: admin
comments: true
date: 2012-06-05 22:52:59+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2012/06/05/1345
slug: дело-о-пропавшем-файле-ammintrin-h
title: Дело о пропавшем файле 'ammintrin.h'.
wordpress_id: 1345
categories:
- itblogs
tags:
- Программирование
- SDK
- Visual Studio
---

Начну издалека. Мой любимый редактор кода на данный момент - [Sublime Text 2](http://www.sublimetext.com/2). До него я пользовался [Notepad2](http://www.flos-freeware.ch/notepad2.html), [Source Insight](http://www.sourceinsight.com/), [Far](http://www.farmanager.com/) (естественно после того, как появился [Colorer](http://colorer.sourceforge.net/farplugin.html)). Что было до Far-а с Colorer-ом я уже не очень помню. Точно был Borland Pascal и Turbo C. Редактор кода Visual Studio в этом списке должен быть где-то между Borland-ом и Far-ом. Не помню, чтобы я пользовался им продолжительное время. 

Отладчику из Visual Studio повезло чуть больше, так как правильно держать WinDbg я научился уже после замены Far-а на Notepad2 пополам с Source Insight. Остальной инструментарий из набора Visual Studio я использую не очень часто, особенно учитывая, что компилятор и другие инструменты все равно есть в отдельно стоящем SDK. Так и получается, что сама по себе Visual Studio мне в общем-то и не нужна.

Единственная неприятность заключается в том, что такая конфигурация (SDK есть, а Visual Studio нет) явно попадает в категорию экзотики. И, как следствие, не поддерживается и не тестируется как следует. Приходится самому.

<!-- more -->Последняя проблема вылезла в самый неожиданный момент. Мне понадобилось обновить компилятор из SDK до версии из Visual Studio 2010 SP1. Зачем понадобилось - это отдельная история. На сайте Microsoft соответствующее обновление имеется: [KB2519277](http://www.microsoft.com/en-us/download/details.aspx?id=4422) (и ставиться, надо сказать, не в пример быстрее Visual Studio 2010 SP1). Однако после установки обновления сборка Chrome начала ругаться на отсутсвующий заголовок ‘ammintrin.h’.

Здесь нужно добавить, что в 2010-ой версии Visual Studio с инсталляциями [не заладилось с самого начала](http://www.johndcook.com/blog/2010/04/22/visual-studio-2010-is-a-pig/). Достаточно посмотреть на readme файл к вышеупомянутому обновлению. А если учесть, что само обновление вышло не для того, чтобы обновить версию компилятора и SDK, а как исправление для Visual Studio 2010 SP1, который портил установленный SDK...

Вернемся к нашим баранам. Заголовок ‘ammintrin.h’ включался из ‘intrin.h’, который, в свою очередь, находился в “%ProgramFiles(x86)%\Microsoft Visual Studio 10.0\VC\include”. Что было похоже на проблемы с инсталляцией. Беглый поиск в интернете показал, что проблема решается переустановкой SP1. SP1 мне поставить не удалось в виду отсутствия Visual Studio на машине, так что я переставил SDK и обновление к нему с нуля. Естественно не помогло.

В процессе установки однако, я сохранил копию ‘intrin.h’. Выяснилось, что KB2519277 обновляет ‘intrin.h’, добавляя ссылку на ‘ammintrin.h’, но сам ‘ammintrin.h’ не ставит. 
Покопавшись в интернете еще немного выяснилось (по аналогии с ‘immintrin.h’, ‘pmmintrin.h’), что [‘ammintrin.h’](http://opensource.apple.com/source/gcc/gcc-5646/gcc/config/i386/ammintrin.h) должен содержать intrinsics для SSE4A, которые специфичны AMD и в проекте не используются. 



<blockquote>[http://docs.oracle.com/cd/E24457_01/html/E21991/gliwk.html](http://docs.oracle.com/cd/E24457_01/html/E21991/gliwk.html):
Note that ammintrin.h is published by AMD and is not included in any of the Intel intrinsic headers. ammintrin.h includes pmmintrin.h, so by including ammintrin.h, all AMD SSE4A as well as Intel SSE3, SSE2, SSE and MMX functions are declared.</blockquote>



Родилось простое решение - был создан пустой заголовок ‘ammintrin.h’ и положен рядышком с ‘intrin.h’. Тем, кому функции все-таки нужны, могу посоветовать восстановить их [по образцу](http://opensource.apple.com/source/gcc/gcc-5646/gcc/config/i386/ammintrin.h) либо таки скопировать этот файл с машины, где стоит SP1 (но это не спортивно). :-)

