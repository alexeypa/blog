---
author: admin
date: 2007-12-06 06:35:35+00:00
aliases:
- /2007/12/05/268
slug: эта-страшная-функция-getrawinputdevicelist
title: Эта страшная функция GetRawInputDeviceList
wordpress_id: 268
tags:
- Дизайн
- Программирование
- Win32
---

Функцию [GetRawInputDeviceList](http://msdn2.microsoft.com/en-us/library/ms645598.aspx) можно смело приводить в качестве антипримера правильно спроектированного API. Эта функция используется для получения списка описателей устройств ввода (raw input devices). Ничего сложного. Прототип функции тоже выглядит довольно невинно - всего три параметра, и, как кажется по началу, назначение каждого довольно очевидно.

```cpp
UINT GetRawInputDeviceList(
    __out_opt PRAWINPUTDEVICELIST pRawInputDeviceList,
    __inout PUINT puiNumDevices,
    __in UINT cbSize
    );
```

Это заблуждение быстро рассеивается, стоит только почитать MSDN. Первый параметр - это просто указатель на буфер, в который пишется массив структур RAWINPUTDEVICELIST. Пока всё нормально. А вот второй параметр - это нечто. Итак:

> Pointer to a variable. If _pRawInputDeviceList_ is NULL, it specifies the number of devices attached to the system. Otherwise, it contains the size, in bytes, of the preallocated buffer pointed to by _pRawInputDeviceList_. However, if *_puiNumDevices_ is smaller than needed to contain **RAWINPUTDEVICELIST** structures, the required buffer size is returned here.

Это указатель на переменную. Если переданный указатель pRawInputDeviceList равен NULL, то в этой переменной возвращается количество устройств, т.е. количество _элементов_ массива. Если pRawInputDeviceList не равен NULL, то эта переменная задаёт размер буфера на который указывает pRawInputDeviceList _в байтах_. Если при этом буфер оказался слишком мал, то функция возвратит в этой переменной необходимый размер буфера _в байтах_.

Т.е. что получается. При первом вызове функции необходимый размер буфера возвращается в виде количества элементов массива. Во время второго вызова этот же размер уже указывается в байтах, полностью дискредитируя имя параметра «puiNumDevices».

Третий параметр задаёт размер структуры RAWINPUTDEVICELIST. То есть этот параметр всегдя должен быть равен sizeof(RAWINPUTDEVICELIST)! Теоретически этот параметр может использоваться для поддержки разных версий RAWINPUTDEVICELIST, но в свете выкрутасов с puiNumDevices, меня гложут смутные сомнения.

Но и это еще не всё. Интерпретация возвращаемого значения тоже не очевидна. При успешном завершении функции, возвращаемое значение равно нулю, если pRawInputDeviceList равен NULL. Если pRawInputDeviceList не равен NULL, то функция возвращает количество элементов записанных в буфер. Что мешает всегда возвращать количество устройств - не понятно. Если функция завершается ошибкой, то всегда возвращается -1. Если причина ошибки - недостаточный размер буфера, то *puiNumDevices указывается необходимый размер.

Что интересно, привести эту функцию в божеский вид совсем не сложно. Достаточно прекратить игры с указанием размера буфера в разных единицах, упростить интерпретацию возвращаемого значения и убрать ненужный параметр:

```cpp
BOOL GetRawInputDeviceList(
    __out_opt PRAWINPUTDEVICELIST pBuffer,
    __inout PUINT puiNumDevices
    );
```

PS: Только не спрашивайте, почему так не сделали с самого начала. Самому интересно. 
