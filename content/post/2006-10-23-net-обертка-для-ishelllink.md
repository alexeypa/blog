---
author: admin
date: 2006-10-22T22:30:31-07:00
aliases:
- /2006/10/22/87
title: .NET обертка для IShellLink
slug: 87
tags:
- COM
- Программирование
- PowerShell
---

Наконец-то дописал .NET обертку для IShellLink (см. серию постов начиная с [Shortcuts, shell and COM apartments.]({{< relref "2006-10-04-shortcuts-shell-and-com-apartments.md" >}})). Теперь можно создавать и редактировать ярлыки прямо из PowerShell. :-)

Вот [ссылка на исходный код проекта](/2006/10/ShellLink_src.zip). Немного позже, если дойдут руки, выложу ссылку на готовую инсталляцию. 

<!--more-->Вся полезная функциональность реализуется одним классом – ShellLink, который объединяет в себе три интерфейса: IShellLink, IShellLinkDataList и IPersistFile. Большая часть методов этих интерфейсов была переделана в .NET свойства для удобства использования.

PowerShell и CLSID_ShellLink используют разные модели COM apartments: PowerShell использует MTA, а CLSID_ShellLink, как и большинство объектов Shell, - STA. В результате, не получается вызывать методы интерфейса IShellLinkDataList, который не поддерживает маршалинг через границу apartments. Для решения этой проблемы используется ShellPS.dll, которая представляет собой не что иное, как proxy/stub DLL для интерфейса IShellLinkDataList (см. [COM marshalling: создание proxy/stub на коленке.]({{< relref "2006-10-12-com-marshalling-создание-proxystub-на-коленке.md" >}})).

В собранном виде весь проект состоит из двух библиотек: ShellLib.dll, которая содержит реализацию класса ShellLink и всех вспомогательных классов, и ShellPS.dll. Обе библиотеки собираются с помощью WDK, причём для сборки ShellLib.dll требуется .NET библиотеки из поставки Visual Studio .NET 2005. Эта комбинация потребовала использования нетривиальных возможностей SOURCES в виде директивы LINKER_OPTIDATA.

Перед использованием, скомпилированные DLL нужно зарегистрировать:

    regsvr32 ShellPS.dll
    gacutil /i ShellLib.dll

После чего можно запустить PowerShell и исследовать новые возможности. 

    # Загружаем ShellLib.dll
    [System.Reflection.Assembly]::Load(
        "shelllib, Version=1.0.1.1, Culture=neutral, 
        PublicKeyToken=e0a879bef00d4c8e, 
        processorArchitecture=x86")
    | out-null

    # Открываем ярлык "Command Prompt.lnk"
    $filename = $env:USERPROFILE + 
        "\\Start Menu\\Programs\\Accessories\\Command Prompt.lnk"

    $link = new-object ShellLib.ShellLink
    $link.Load(
        $filename, 
        [ShellLib.EPersistFileModeFlags]::STGM_READWRITE)

    $link

Последняя команда выведет текущие значения основных свойств ярлыка:

[![](/2006/10/ShellLink_values.thumbnail.png)](/2006/10/ShellLink_values.png)

Покажем список всех доступных методов и свойств:

    $link | get-member

[![](/2006/10/ShellLink_methods.thumbnail.png)](/2006/10/ShellLink_methods.png)

Свойство ConsoleProps соответствует вкладкам “Options”, “Font”, “Layout” и “Colors” в стандартном окне свойств ярлыка. В данный момент свойство ConsoleProps не задано, что соответствует всем значениям по умолчанию: 

[![](/2006/10/ShellLink_DefaultLayout.thumbnail.png)](/2006/10/ShellLink_DefaultLayout.png)

Попробуем задать свой размер окна и шрифт:

    $props = new-object ShellLib.NtConsoleProps
    $props.wFillAttribute = 7
    $props.wPopupFillAttribute = 245
    $props.dwScreenBufferSize = new-object System.Drawing.Point(180, 3000)
    $props.dwWindowSize = new-object System.Drawing.Point(180, 79)
    $props.dwFontSize = new-object System.Drawing.Point(7, 12)
    $props.uFontFamily = 54
    $props.uFontWeight = 400
    $props.FaceName = “Lucida Console”
    $props.uCursorSize = 15
    $props.bQuickEdit = 1
    $props.bInsertMode = 1
    $props.uHistoryBufferSize = 50
    $props.uNumberOfHistoryBuffers = 4
    $link.ConsoleProps = $props

Может показаться, что параметров слишком много, но на самом деле все значения можно просто скопировать из свойств созданного стандартными средствами ярлыка.

Теперь можно сохранить полученные изменения.

    $link.Save($filename, 1)

В результате всех этих действий вот такой результат:

[![](/2006/10/ShellLink_NewLayout.thumbnail.png)](/2006/10/ShellLink_NewLayout.png)

[![](/2006/10/ShellLink_NewFont.thumbnail.png)](/2006/10/ShellLink_NewFont.png)

Осталось только оформить это всё в один скрипт и готово! :-)
