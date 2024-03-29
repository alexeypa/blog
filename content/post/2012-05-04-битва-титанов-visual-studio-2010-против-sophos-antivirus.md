---
author: admin
date: 2012-05-04T10:50:56-07:00
aliases:
- /2012/05/04/1317
title: 'Битва титанов: Visual Studio 2010 против Sophos Antivirus'
slug: 1317
tags:
- Инструменты
- Программирование
- WTF
---

По рассылке пришло описание бага ну просто феерической кавайности: [http://connect.microsoft.com/VisualStudio/feedback/details/649139/vs2010-does-complete-rebuild-based-on-completely-unrelated-file](http://connect.microsoft.com/VisualStudio/feedback/details/649139/vs2010-does-complete-rebuild-based-on-completely-unrelated-file). Если вкраце, то присутсвие Sophos Antivirus на машине, заставляет Visual Studio делать полный билд вместо инкрементального. Почему? Потому что MSBuild полагает, что файл “%ProgramData%\Sophos\Sophos Anti-Virus\config\Config.bops” (который, понятно, ни к MSBuild, ни к собираемому проекту никак не относится) является вводом каждого target’а в проекте. По какой-то причине, этот файл обновляется очень часто, что и вызывает полную пересборку всего проекта. WTF?

[![](/2012/05/house_wtf.jpg)](/2012/05/house_wtf.jpg)

<!--more-->Оказывается, чтобы определить зависимости между файлами в проекте, MSBuild внедряется в процессы компилятора, линкера и перехватывает чтение и запись файлов (что одновременно и гениально, и не очень умно). Sophos Antivirus, мало чем отличаясь по своей коварности от других антивирусов, также внедряется в каждый процесс на машине (и, стало быть, творит там свои черные дела). Помимо всего прочего, Sophos Antivirus читает “%ProgramData%\Sophos\Sophos Anti-Virus\config\Config.bops”. Ну а посольку делает он это от имени процесса куда внедрился, то MSBuild заносит этот конфигурационный файл в список зависимостей.

[![](/2012/05/house_facepalm.jpg)](/2012/05/house_facepalm.jpg)

PS. Вот этот комментарий к ответу Дэна (инженера из Microsoft) с описанием в чем, собственно, проблема очень порадовал:

> Hello Dan,  
> and thanks for your response.  
> Unfortunately I was not able to comprehend your response.  
> ...

> Здраствуйте Дэн и спасибо за ваш ответ.  
> К сожалению, я не смог понять ваш ответ.  
> ...

:-)
