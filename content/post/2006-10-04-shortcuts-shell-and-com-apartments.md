---
author: admin
date: 2006-10-04T09:20:00-07:00
aliases:
- /2006/10/04/76
title: Shortcuts, shell and COM apartments
slug: 76
tags:
- COM
- Программирование
---

_Дурная голова ногам покоя не даёт._

Поставил свежий WDK и понял, что мне жутко надоело каждый раз исправлять все ярлыки, меняя шрифт на Lucida Console и размеры окна со стандартных 80x25 на более удобоваримые 170x75. Зачесались руки автоматизировать это дело. 

<!--more-->После непродолжительной борьбы желание сделать все красиво победило здравый смысл и заглушило внутренний голос, который что-то невнятно бубнил про "простые решения". Короче захотелось написать .NET обертку для стандартных IShellLink и IShellLinkDataList чтобы её можно было использовать из PowerShell. Сказано-сделано. Нашёл пару примеров на [Code Project](http://www.codeproject.com/managedcpp/mcppshortcuts.asp) и [vbAccelerator](http://vbaccelerator.com/home/NET/Code/Libraries/Shell_Projects/Creating_and_Modifying_Shortcuts/article.asp) и принялся за дело. 

С IShellLink все работало как по маслу. Дело застопорилось том, что QueryInterface наотрез отказывался возвращать IShellLinkDataList, утверждая, что такого интерфейса CLSID_ShellLink не поддерживает (E_NOINTERFACE). Покопавшись немного в интернете наткнулся на [вот эту заметку](http://blogs.msdn.com/oldnewthing/archive/2004/12/13/281910.aspx). Оказалось, что все дело в разных COM Apartments. CLSID_ShellLink использует Apartment Threading Model, а PowerShell - Multithreaded Apartment. Кроме того, оказалось, что IShellLinkDataList вообще не зарегестрирован в реестре и, соответственно, для него не задан proxy (ProxyStubClsid32). Иными словами нормально работать с IShellLinkDataList можно только из Single-Threaded Apartment.

Теперь думаю как лучше обойти это ограничение. Вариантов пока всего два. Первый - создавать CLSID_ShellLink в отдельном потоке, выставив для него STA модель. Собственно говоря, это тоже самое, что предлагает Mow в [своем блоге](http://mow001.blogspot.com/2005/10/msh-clipboard-use-workaround.html). Второе решение - написать proxy для IShellLinkDataList, мне нравиться гораздо больше в силу своей универсальности. Сложность в том, что я этого никогда не делал и весьма смутно представляю себе с чего надо начинать. Посмотрим, что из этого получится.
