---
author: admin
comments: true
date: 2011-07-25 03:55:56+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2011/07/24/1132
slug: можно-ли-использовать-функцию-rtlcapturecontext-из-x86
title: Можно ли использовать функцию RtlCaptureContext() из x86 кода?
wordpress_id: 1132
categories:
- itblogs
tags:
- Программирование
- совместимость
- Windows
- x86
---

Вопрос из почты:



<blockquote>The question is really simple: could we use RtlCaptureContext on X86? The MSDN ([http://msdn.microsoft.com/en-us/library/ms680659(v=VS.85).aspx](http://msdn.microsoft.com/en-us/library/ms680659(v=VS.85).aspx)) says it’s only for 64 but the bug is for X86 and I see some kernel code are using it on x86.
</blockquote>





<blockquote>Вопрос на самом деле очень прост: можем ли мы использовать функцию RtlCaptureContext на x86? MSDN говорит, что эта функция только для 64-х бит но баг-репорт (имеется ввиду баг-репорт, ранее упомянутый в письме) воспроизводится для x86 и я вижу, что код в ядре использует эту функцию на x86.
</blockquote>



Ответ: можно. Действительно, упомянутая страница MSDN утверждает, что:



<blockquote>The following functions are used only on 64-bit Windows.</blockquote>





<blockquote>Следующие функции используются только в 64-х разрядных версиях Windows.</blockquote>



Однако, страница, описывающая саму функцию [RtlCaptureContext()](http://msdn.microsoft.com/en-us/library/ms680591(v=VS.85).aspx) указывает Windows XP и Windows Server 2003  в качестве минимальных версий клиента и сервера. Сравните с функцией [RtlAddFunctionTable()](http://msdn.microsoft.com/en-us/library/ms680588(v=VS.85).aspx), действительно не реализованной на x86. Минимальные версии клиента и сервера для неё - Windows XP Professional x64 Edition и 64-bit editions of Windows Server 2003 соответственно.

Другой способ удостовериться в этом – проверить таблицу экспорта NTDLL. Хотя такой способ, конечно, не дает никакой информации о том, документирована функция (иными словами – поддерживается ли обратная совместимость для неё) или нет.



```no-highlight
C:\>link /dump /exports c:\Windows\SysWOW64\ntdll.dll | findstr RtlCaptureContext
        667  28D 00046B2B RtlCaptureContext

C:\>link /dump /exports c:\Windows\SysWOW64\ntdll.dll | findstr RtlAddFunctionTable

C:\>
```

