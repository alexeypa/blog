---
author: admin
date: 2006-12-25T23:19:55-07:00
aliases:
- /2006/12/25/120
title: В чём разница между HKEY и HANDLE?
slug: 120
tags:
- Программирование
- Реестр
- Win32
- Windows
---

В комментариях к посту [про обертку для HANDLE]({{< relref "post/2006-11-01-c-обёртка-для-handle.md" >}}) зашла речь о разнице между HKEY и HANDLE. С одной стороны, они имеют много общего:

  * Ключ реестра это такой же объект ядра, как и файл. К примеру, CreateFile и RegCreateKeyEx используют одинаковые параметры для указания требуемого уровня доступа и прав доступа к ключу/файлу;

  * HKEY, также как и HANDLE, можно скопировать с помощью функции DuplicateHandle.

<!--more-->С другой стороны, есть и отличия:

  * Для закрытия HKEY нужно использовать функцию RegCloseKey вместо CloseHandle;

  * Существуют зарезервированные значения описателя HKEY: HKEY_CLASSES_ROOT, HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE и т.д. в то время как HANDLE не имеет таких ограничений;

  * DuplicateHandle не может копировать описатели ключей реестра полученные с помощью функции RegConnectRegistry.

В чём тут дело? Дело в том, что только часть функциональности реестра реализована в ядре. Она включает в себя базовые операции (создание, удаление, чтение, запись и т.д.) для работы с локальными ключами реестра. Остальные функции реализуются библиотекой advapi32.dll и работают в пользовательском режиме:

  * Доступ к удаленному реестру с помощью RegConnectRegistry;

  * Доступ к ветке HKEY_PERFORMANCE_DATA;

  * Преобразование Win32 представления реестра в Native представление;

  * Перенаправление реестра (registry redirection) на 64-х битных системах для 64-х битных приложений.

“Ядерная” часть функциональности доступна через функции Native API: [NtCreateKey](http://undocumented.ntinternals.net/UserMode/Undocumented%20Functions/NT%20Objects/Key/NtCreateKey.html), [NtOpenKey](http://undocumented.ntinternals.net/UserMode/Undocumented%20Functions/NT%20Objects/Key/NtOpenKey.html) и т.д. При сравнении этих функций с функциями Win32 API видно, что Native API использует “классические” описатели HANDLE вместо HKEY:

```cpp
NTSYSAPI
NTSTATUS
NTAPI
NtCreateKey(
    OUT PHANDLE             pKeyHandle,
    IN ACCESS_MASK          DesiredAccess,
    IN POBJECT_ATTRIBUTES   ObjectAttributes,
    IN ULONG                TitleIndex,
    IN PUNICODE_STRING      Class OPTIONAL,
    IN ULONG                CreateOptions,
    OUT PULONG              Disposition OPTIONAL);
```

Второе, не столь явное отличие состоит в том, что на уровне Native API реестр выглядит совсем по-другому. Вместо нескольких корневых псевдоключей HKEY_XXX используется единственный ключ “\REGISTRY” с двумя подключами “\USER” и “\MACHINE”:

```no-highlight
\REGISTRY
    \USER
        \.DEFAULT
        \S-FOO
        \S-BAR
    \MACHINE
        \HARDWARE
        \SAM
        \SECURITY
        \SOFTWARE
        \SYSTEM
```

Функции RegCreateKey(Ex) и RegOpenKey(Ex) отображают пути как показано в следующей таблице:

<table width="100%" border="1" >
  <tr>
    <td>HKEY_CLASSES_ROOT</td>
    <td>Объединяет в один ключ:
      <ul>
        <li>\REGISTRY\USER\S-XXX\SOFTWARE\CLASSES</li>
        <li>\REGISTRY\USER\S-XXX_CLASSES</li>
        <li>\REGISTRY\MACHINE\SOFTWARE\CLASSES</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>HKEY_CURRENT_CONFIG</td>
    <td>\REGISTRY\MACHINE\System\CurrentControlSet\Hardware Profiles\Current</td>
  </tr>
  <tr>
    <td>HKEY_CURRENT_USER</td>
    <td>\REGISTRY\USER\S-XXX</td>
  </tr>
  <tr>
    <td>HKEY_LOCAL_MACHINE</td>
    <td>\REGISTRY\MACHINE</td>
  </tr>
  <tr>
    <td>HKEY_USERS</td>
    <td>\REGISTRY\USER</td>
  </tr>
</table>

См. [Predefined Keys](http://msdn2.microsoft.com/en-us/library/ms724836.aspx).

В случае доступа к одной из вервей реестра из этой таблицы различия между Win32 и Native API функциями заканчиваются. Win32 функции просто преобразовывают полученный HANDLE в HKEY перед тем, как вернуть описатель приложению. Именно для этих описателей работают функции DuplicateHandle и GetHandleInformation.

При обращении к реестру на удаленной машине Win32 API функции выполняют удалённый вызов по RPC протоколу. Значение описателя, возвращаемое в этом случае, не является значением типа HANDLE на локальной машине и вызов (Nt)CloseHandle для этого описателя вернет ошибку. Чтобы различать два типа описателей RegXxx функции устанавливают младший бит “удалённого” описателя в единицу. Это возможно, поскольку два младших бита обычно не используются. Соответственно, когда RegCloseKey получает такой описатель, вместо вызова NtCloseHandle освобождается удаленный описатель.

_Мне, кстати, пока не удалось разобраться, как именно работает этот механизм, так что я могу сильно ошибаться._

Аналогично, в случае доступа к ветке HKEY_PERFORMANCE_DATA вместо обращения к реестру выполняется вызов одной функции из perflib.
