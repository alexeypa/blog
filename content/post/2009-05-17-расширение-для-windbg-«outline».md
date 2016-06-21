---
author: admin
date: 2009-05-16T22:45:18-07:00
aliases:
- /2009/05/16/512
title: 'Расширение для WinDbg: «Outline».'
slug: 512
tags:
- Отладка
- Outline
---

Мне частенько приходится разбираться с отладкой исключений, произошедших из-за порчи стека или на фоне порчи стека. В таких случаях обычно приходится трассировать стек вручную. Дело это муторное, поэтому я решил написать расширение для WinDbg, несколько облегчающее эту задачу.

<!--more-->На данный момент реализована только одна команда «!fnframe». Она показывает структуру стекового фрейма для произвольной функции: локальные переменные и параметры, сохраненные регистры, указатель фрейма. На x64 помимо символов используется сгенерированная компилятором [unwind information](http://msdn.microsoft.com/en-us/library/ms794374.aspx), что обеспечивает большую достоверность результатов. Поддержка Itanium пока в планах. 

Скачать:

  * [Outline 1.0.1 x86](/outline/1.0.1/x86/outline.dll) (SHA1: 6dd2edb49940ac4d48016e49fb5c6ffe4d53d56d)

  * [Outline 1.0.1 x64](/outline/1.0.1/x64/outline.dll) (SHA1: 47b6c5e9b63c783126cc823e979a8d2882c6492f)

Примеры:

x86 сборка Far Manager 2.0 с включенным frame pointer omission:

```no-highlight
0:000:x86> .load outline
0:000:x86> !fnframe far!wmain
 Start of frame               --> -0x78
   -0x78   Saved registers      : 0x10 bytes
   -0x64   strViewName          : class UnicodeString, 0x4 bytes
   -0x60   strEditName          : class UnicodeString, 0x4 bytes
   -0x5c   StartLine            : int, 0x4 bytes
   -0x58   CntDestName          : int, 0x4 bytes
   -0x54   DestNames            : class UnicodeString [2], 0x8 bytes
   -0x4c   RectoreConsole       : int, 0x4 bytes
   -0x48   StartChar            : int, 0x4 bytes
   -0x44   __ConsoleRestore     : class TConsoleRestore, 0x24 bytes
   -0x20   buf                  : char [15], 0xf bytes
   +0x0    Return address       : 0x4 bytes
   +0x4    Argc                 : int, 0x4 bytes
   +0x8    Argv                 : wchar_t **, 0x4 bytes
 End of frame                 --> +0xc
0:000:x86>
```

x64 сборка того же Far Manager 2.0:

```no-highlight
0:000> !fnframe far!wmain
 Start of frame               --> +0x0
   +0x0    rcx home             : 0x8 bytes
   +0x8    rdx home             : 0x8 bytes
   +0x10   r8 home              : 0x8 bytes
   +0x18   r9 home              : 0x8 bytes
   +0x40   strEditName          : class UnicodeString, 0x8 bytes
   +0x48   strViewName          : class UnicodeString, 0x8 bytes
   +0x50   DestNames            : class UnicodeString [2], 0x10 bytes
   +0x60   __ConsoleRestore     : class TConsoleRestore, 0x30 bytes
   +0x98   buf                  : char [15], 0xf bytes
   +0xb0   r15                  : 0x8 bytes
   +0xb8   r14                  : 0x8 bytes
   +0xc0   r13                  : 0x8 bytes
   +0xc8   r12                  : 0x8 bytes
   +0xd0   rdi                  : 0x8 bytes
   +0xd8   rsi                  : 0x8 bytes
   +0xe0   rbp                  : 0x8 bytes
   +0xe8   Return address       : 0x8 bytes
 End of frame                 --> +0xf0
   +0xf0   Argc                 : int, 0x4 bytes
   +0xf8   Argv                 : wchar_t **, 0x8 bytes
   +0x100  rbx                  : 0x8 bytes
0:000>
```

Публичные символы не описывают ntdll!KiUserExceptionDispatcher (точка входа диспетчера исключений пользовательского режима), но включенная в бинарный файл unwind information дает кое-какое представление об этой функции:

```no-highlight
0:000> !fnframe ntdll!KiUserExceptionDispatcher
 Start of frame               --> +0x0
   +0x0    rcx home             : 0x8 bytes
   +0x8    rdx home             : 0x8 bytes
   +0x10   r8 home              : 0x8 bytes
   +0x18   r9 home              : 0x8 bytes
   +0x90   rbx                  : 0x8 bytes
   +0xa0   rbp                  : 0x8 bytes
   +0xa8   rsi                  : 0x8 bytes
   +0xb0   rdi                  : 0x8 bytes
   +0xd8   r12                  : 0x8 bytes
   +0xe0   r13                  : 0x8 bytes
   +0xe8   r14                  : 0x8 bytes
   +0xf0   r15                  : 0x8 bytes
   +0x200  xmm6                 : 0x10 bytes
   +0x210  xmm7                 : 0x10 bytes
   +0x220  xmm8                 : 0x10 bytes
   +0x230  xmm9                 : 0x10 bytes
   +0x240  xmm10                : 0x10 bytes
   +0x250  xmm11                : 0x10 bytes
   +0x260  xmm12                : 0x10 bytes
   +0x270  xmm13                : 0x10 bytes
   +0x280  xmm14                : 0x10 bytes
   +0x290  xmm15                : 0x10 bytes
   +0x590  Machine frame        : 0x28 bytes
 End of frame                 --> +0x5b8
0:000>
```
