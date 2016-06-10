---
author: admin
comments: true
date: 2007-05-20 22:36:58+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2007/05/20/186
slug: an-extended-error-has-occurred
title: An extended error has occurred.
wordpress_id: 186
categories:
- itblogs
tags:
- Troubleshooting
- Windows
---

Пару месяцев назад, я, за какой-то надобностью, попытался установить компонент Peer-to-Peer из сетевых компонент Windows XP, но у меня ничего не вышло. Сначала инсталлятор запросил дополнительные файлы из “C:\Windows\ServicePackFiles\i386”, которые я к тому времени успешно удалил за ненадобностью, затем он отказался от одноимённых файлов с инсталляционного диска Windows XP и, наконец, инсталляция прервалась, выдав напоследок очень понятное сообщение: «An extended error has occurred».

<!-- more -->«Ну, нет - так нет», подумал я тогда и забыл о проблеме. Однако на днях захотелось выяснить, в чём же было дело. Повторная инсталляция закончилась всё тем же невразумительным сообщением об ошибке. При этом в каталоге Windows обнаружилось несколько свежих логов, в том числе «setupapi.log»:


    
    <code class="no-highlight">[2007/05/17 19:36:17 2760.37]
    #-198 Command line processed: "C:\\WINDOWS\\system32\\sysocmgr.exe" /y /i:C:\\WINDOWS\\system32\\sysoc.inf
    #-006 Setting security on key HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\PeerNet\\PNRP to "D:(A;OICI;KA;;;SY)(A;OICI;KA;;;BA)(A;OICI;KA;;;LS)(A;OICI;KA;;;CO)(A;OICI;KR;;;AU)"
    #E033 Error 1208: An extended error has occurred.
    #-035 Processing service Add/Delete section [p2p.Services].
    #E277 Add Service: Failed to secure service "p2psvc". Error 1208: An extended error has occurred.
    #E033 Error 1208: An extended error has occurred.
    #E275 Error while installing services. Error 1208: An extended error has occurred.
    </code>



Очевидно, что что-то не так было с установкой службы «p2psvc». В реестре не обнаружилось никаких следов службы «p2psvc». Копание в .inf файлах, ответственных за установку этой службы, ясности тоже не прибавило. Однако Sysnternal’овский Process Monitor показал, что происходит во время инсталляции – сервис под именем «p2psvc» регистрируется, как и положено, однако из-за возникающей ошибки все изменения в реестре откатываются назад. Гм.

Попробовал зайти с другого конца – выяснить какую роль играет «sysocmgr.exe». Оказалось что это тот самый инсталлятор, который запускается при нажатии на «Add/Remove Windows Components». 



![Windows Components Wizard](http://blog.not-a-kernel-guy.com/wp-content/uploads/2007/05/windows_components_wizard.png)



Если запустить его без параметров, показывается подсказка по допустимым параметрам командной строки, один из которых, «/f» - вызывает принудительную переустановку компонент «с чистого листа»:



![Windows XP Setup](http://blog.not-a-kernel-guy.com/wp-content/uploads/2007/05/windows_xp_setup.png)



Казалось бы, вот оно решение, но на появление непонятной ошибки этот ключ никак не повлиял.

В конце концов поиск в Google вывел меня на страницу [JSI FAQ](http://www.jsifaq.com/SF/Tips/Tip.aspx?id=7558). Не могу сказать, что описание проблемы было сильно похоже на мою, но сочетание слов security, setup и сообщения «Setup cannot copy the file» имели к ней прямое отношение. Как ни странно, восстановление secedit.sdb  с помощью вот этой команды помогло:


    
    <code class="no-highlight">esentutl /p %SystemRoot%\\security\\database\\secedit.sdb</code>



И после перезагрузки установка прошла как по маслу…

