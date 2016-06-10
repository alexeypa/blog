---
author: admin
comments: true
date: 2011-12-17 06:47:53+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2011/12/16/1230
slug: почему-process-totalprocessortime-не-работает-для-удаленных
title: Почему Process.TotalProcessorTime не работает для удаленных процессов.
wordpress_id: 1230
categories:
- default
---

Вопрос из почты:



<blockquote>Скажите пожалуйста. Есть тут такой класс, верней конкретно одно из его свойств [http://msdn.microsoft.com/en-us/library/system.diagnostics.process.totalprocessortime.aspx](http://msdn.microsoft.com/en-us/library/system.diagnostics.process.totalprocessortime.aspx). Сказано, что его можно получить только локально. А почему? Из-за этого, собсно, не работает нормально командлет get-process, когда им пытаешься запросить процессы удаленной машины. Верней работает, но частично. Колонка CPU(s) в его вводе пустая.
</blockquote>



Короткий ответ: по всей видимости, потому, что нужный  счетчик не доступен через HKEY_PERFORMANCE_DATA.

Длинный ответ: с .NET я сталкиваюсь не очень часто. Ничего лучше, чем банально взять дизассемблер для IL (intermediate language) и посмотреть на код, мне в голову не пришло. Ildasm.exe входит в состав SDK, но есть и другие варианты, - например [ReSharper](http://www.jetbrains.com/resharper/).

<!-- more -->


    
    <code class="no-highlight">Ildasm.exe c:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.dll</code>



IL достаточно прост, чтобы читать, не заглядывая в спецификацию. Основные моменты понятны и так, а разбираться с деталями мне как-то еще не требовалось. Интересующий нас метод очень прост:


    
    <code class="no-highlight">.method public hidebysig specialname instance valuetype [mscorlib]System.TimeSpan 
            get_TotalProcessorTime() cil managed
    {
      // Code size       19 (0x13)
      .maxstack  8
      IL_0000:  ldarg.0
      IL_0001:  ldc.i4.4
      IL_0002:  call       instance void System.Diagnostics.Process::EnsureState(valuetype System.Diagnostics.Process/State)
      IL_0007:  ldarg.0
      IL_0008:  call       instance class System.Diagnostics.ProcessThreadTimes System.Diagnostics.Process::GetProcessTimes()
      IL_000d:  callvirt   instance valuetype [mscorlib]System.TimeSpan System.Diagnostics.ProcessThreadTimes::get_TotalProcessorTime()
      IL_0012:  ret
    } // end of method Process::get_TotalProcessorTime</code>



Вызов Process::GetProcessTimes() возвращает заполненную структуру ProcessThreadTimes, содержащую, кроме всего прочего, уже вычисленные значения user time и kernel time. Последующий вызов ProcessThreadTimes::get_TotalProcessorTime() просто складывает эти два значения и возвращает полученный результат.

Если взглянуть на Process::GetProcessTimes(), то видно, что тот просто вызывает Win32 функцию GetProcessTimes() и складывает полученные значения kernel и user time в возвращаемую структуру:


    
    <code class="no-highlight">...
    IL_0059:  ldflda     int64 System.Diagnostics.ProcessThreadTimes::create
    IL_005e:  ldloc.0
    IL_005f:  ldflda     int64 System.Diagnostics.ProcessThreadTimes::exit
    IL_0064:  ldloc.0
    IL_0065:  ldflda     int64 System.Diagnostics.ProcessThreadTimes::kernel
    IL_006a:  ldloc.0
    IL_006b:  ldflda     int64 System.Diagnostics.ProcessThreadTimes::user
    IL_0070:  call       bool Microsoft.Win32.NativeMethods::GetProcessTimes(class Microsoft.Win32.SafeHandles.SafeProcessHandle,
                                                                             int64&,
                                                                             int64&,
                                                                             int64&,
                                                                             int64&)
    ...</code>



Функция GetProcessTimes() работает только для локальных процессов, так как идентифицирует процесс по переданному NT handle. Посмотрим теперь на какое-нибудь другое свойство, которое работает, в том числе, и для удаленных процессов. К примеру, на Process.HandleCount:


    
    <code class="no-highlight">.method public hidebysig specialname instance int32 
            get_HandleCount() cil managed
    {
      // Code size       19 (0x13)
      .maxstack  8
      IL_0000:  ldarg.0
      IL_0001:  ldc.i4.8
      IL_0002:  call       instance void System.Diagnostics.Process::EnsureState(valuetype System.Diagnostics.Process/State)
      IL_0007:  ldarg.0
      IL_0008:  ldfld      class System.Diagnostics.ProcessInfo System.Diagnostics.Process::processInfo
      IL_000d:  ldfld      int32 System.Diagnostics.ProcessInfo::handleCount
      IL_0012:  ret
    } // end of method Process::get_HandleCount</code>



В этом случае значение берется из структуры ProcessInfo, которая, по всей видимости, заполняется методом EnsureState(). Последний, в свою очередь, делает несколько не относящихся к делу проверок и вызывает ProcessManager::GetProcessInfos(), чтобы получить желаемую структуру. Еще через пару уровней вложенности становится понятно, что информация об удаленных процессах добывается через класс NtProcessManager, который читает счетчики из HKEY_PERFORMANCE_DATA удаленной машины. Подсказки в коде, ведущие к этому заключению выглядят вот так:


    
    <code class="no-highlight">.method private hidebysig static class System.Diagnostics.ProcessInfo[] 
            GetProcessInfos(class System.Diagnostics.<strong>PerformanceCounterLib</strong> 'library') cil managed
    {
    ...
        IL_000e:  ldstr      "<strong>230</strong> 232"
        IL_0013:  callvirt   instance uint8[] System.Diagnostics.PerformanceCounterLib::GetPerformanceData(string)
        IL_0018:  stloc.1</code>



Имя PerformanceCounterLib говорит само за себя. А константа 230 – это идентификатор объекта Process из HKEY_PERFORMANCE_DATA.


    
    <code class="no-highlight">  .locals init (class [mscorlib]System.Collections.Hashtable V_0,
               class [mscorlib]System.Collections.ArrayList V_1,
               valuetype [mscorlib]System.Runtime.InteropServices.GCHandle V_2,
               native int V_3,
               class Microsoft.Win32.NativeMethods/<strong>PERF_DATA_BLOCK</strong> V_4,
               native int V_5,
               class Microsoft.Win32.NativeMethods/<strong>PERF_INSTANCE_DEFINITION</strong> V_6,
               class Microsoft.Win32.NativeMethods/<strong>PERF_COUNTER_BLOCK</strong> V_7,
               int32 V_8,
               class Microsoft.Win32.NativeMethods/<strong>PERF_OBJECT_TYPE</strong> V_9,
               native int V_10,
               native int V_11,
               class [mscorlib]System.Collections.ArrayList V_12,
               int32 V_13,
               class Microsoft.Win32.NativeMethods/<strong>PERF_COUNTER_DEFINITION</strong> V_14,
               string V_15,
               class Microsoft.Win32.NativeMethods/<strong>PERF_COUNTER_DEFINITION</strong>[] V_16,</code>



Структуры PERF_DATA_BLOCK, PERF_INSTANCE_DEFINITION и т.д. сразу напомнили содержимое winperf.h

Получается, что информация об удаленных процессах читается из HKEY_PERFORMANCE_DATA удаленной машины. Почему же нельзя точно также прочитать время, проведенное процессом в user и kernel mode? Видимо потому, что эти счетчики не доступны через HKEY_PERFORMANCE_DATA. Вот какие счётчики доступны для процесса:


    
    <code class="no-highlight">230 Process
    	<strong>144 % Privileged Time</strong>
    	6 % Processor Time
    	<strong>142 % User Time</strong>
    	1410 Creating Process ID
    	684 Elapsed Time
    	952 Handle Count
    	784 ID Process
    	1424 IO Data Bytes/sec
    	1416 IO Data Operations/sec
    	1426 IO Other Bytes/sec
    	1418 IO Other Operations/sec
    	1420 IO Read Bytes/sec
    	1412 IO Read Operations/sec
    	1422 IO Write Bytes/sec
    	1414 IO Write Operations/sec
    	28 Page Faults/sec
    	182 Page File Bytes Peak
    	184 Page File Bytes
    	58 Pool Nonpaged Bytes
    	56 Pool Paged Bytes
    	682 Priority Base
    	186 Private Bytes
    	680 Thread Count
    	174 Virtual Bytes
    	172 Virtual Bytes Peak
    	180 Working Set
    	178 Working Set Peak
    	1478 Working Set - Private</code>



Обратите внимание, что “Privileged Time” и “User Time” измеряются процентах. Т.е. считается текущее использование процессом CPU, а не общее время, проведенное процессом в обоих режимах.

