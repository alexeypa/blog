---
author: admin
comments: true
date: 2008-02-16 05:06:19+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2008/02/15/289
slug: помните-как-я-ругался-на-функцию-getrawinputdevicelist
title: Помните, как я ругался на функцию GetRawInputDeviceList?
wordpress_id: 289
categories:
- itblogs
tags:
- Дизайн
- Программирование
- Win32
---

Оказалось, что [это](http://blog.not-a-kernel-guy.com/2007/12/05/268) была ошибка в документации. Её поправили и посмотрите, [что получилось](http://msdn2.microsoft.com/en-us/library/ms645598.aspx).


<!-- more -->
  

Было:

 

> _puiNumDevices_

> [in, out] Pointer to a variable. If pRawInputDeviceList is NULL, it specifies the number of devices attached to the system. Otherwise, it contains **_the size, in bytes_**, of the preallocated buffer pointed to by pRawInputDeviceList. However, if *puiNumDevices is smaller than needed to contain RAWINPUTDEVICELIST structures, the required **_buffer size_** is returned here.

Стало:


> _puiNumDevices_

> [in, out] Pointer to a variable. If pRawInputDeviceList is NULL, the function populates this variable with the number of devices attached to the system; otherwise, this variable specifies **_the number of RAWINPUTDEVICELIST structures_** that can be contained in the buffer to which pRawInputDeviceList points. If this value is less than the number of devices attached to the system, the function returns **_the actual number of devices_** in this variable and fails with ERROR_INSUFFICIENT_BUFFER.


Самое смешное, что код, вызывающий эту функцию и написанный в соответствии с ошибочной версией документации, все равно работает. Дело в том при первом вызове функции, когда приложение запрашивает размер буфера, оно получает его в виде числа структур RAWINPUTDEVICELIST. А во время второго вызова, хотя и размер указан в байтах (как того требовала документация), функция помещает в буфер ровно столько структур RAWINPUTDEVICELIST, сколько было обнаружено при первом вызове. Естественно, в случае, если количество устройств в системе не изменилось между двумя вызовами, что очень маловероятно.

 

P.S. А Word среагировал на «ругался на функцию» следующим замечанием: «Ошибка в управлении. Ругаться можно с кем-то. В речи малограмотных людей часто употребляется этот оборот вместо «ругать кого либо». Ох, малограмотные мы! Эх…