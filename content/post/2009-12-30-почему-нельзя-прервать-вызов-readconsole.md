---
author: admin
comments: true
date: 2009-12-30 06:26:20+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2009/12/29/726
slug: почему-нельзя-прервать-вызов-readconsole
title: Почему нельзя прервать вызов ReadConsole?
wordpress_id: 726
categories:
- itblogs
tags:
- Консоль
- Программирование
- Windows
---

Представьте, что где-то в коде есть такой кусок:



```cpp
BOOL Res =
    ReadConsole(
        GetStdHandle(STD_INPUT_HANDLE),
        Buffer,
        sizeof(Buffer),
        &ReadChars,
        NULL);
```



Теперь, скажем, нам в какой-то момент нужно корректно прервать вызов [ReadConsole()](http://msdn.microsoft.com/en-us/library/ms684958%28VS.85%29.aspx) (из другого потока). Как это сделать?

<!-- more -->Как выясняется, ни [CancelIoEx()](http://msdn.microsoft.com/en-us/library/aa363792%28VS.85%29.aspx), ни [CancelSynchronousIo()](http://msdn.microsoft.com/en-us/library/aa363794%28VS.85%29.aspx) не работают в этом случае. CancelIoEx() возвращает ошибку ERROR_INVALID_HANDLE, а CancelSynchronousIo() - ERROR_OBJECT_NOT_FOUND. Также интересно, то [GetStdHandle()](http://msdn.microsoft.com/en-us/library/ms683231%28VS.85%29.aspx) возвращает значение “3”, что не очень-то похоже на описатель (handle) ядерного объекта.

Проблема заключается  в том, что консольная подсистема обслуживается системным процессом Csrss (в Windows 7 - Conhost). Консольные функции вроде ReadConsole() на самом деле выполняют RPC вызовы в Csrss, вместо обращения в ядро. Соответственно, прервать текущую операцию можно было бы вызвав CancelIoEx() с описателем LPC порта, поверх которого «ходит» RPC. Правда добраться до этого описателя не очень реально. Да и RPC соединение после такого финта ушами может быть потеряно.

Остаются всякие окольные методы. Во-первых, можно насильно завершить поток, читающий консоль. Во-вторых, можно имитировать консольный ввод с помощью [WriteConsoleInput()](http://msdn.microsoft.com/en-us/library/ms687403%28VS.85%29.aspx), разблокировав тем самым ReadConsole(). В некоторых случаях можно отказаться от построчного ввода и реализовать ReadConsole() в виде надстройки над [ReadConsoleInput()](http://msdn.microsoft.com/en-us/library/ms684961%28VS.85%29.aspx). Хотя этот путь только для настоящих джедаев. В общем, не просто это все…

