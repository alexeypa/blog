---
author: admin
date: 2012-12-05 07:23:13+00:00
aliases:
- /2012/12/04/1437
title: Трассировка описателей (AKA handle tracing)
slug: 1437
tags:
- Инструменты
- Недокументированные функции
- Отладка
- Программирование
- Windows Kernel
---

Начиная с Windows XP в ядро встроена поддержка трассировки описателей ядра (AKA handle tracing). Включение трассировки имеет двойной эффект. Во-первых, все операции с ядерными описателями сохраняются в циклический буфер (откуда их можно потом прочитать). Во-вторых, при любой попытке использовать несуществующий описатель генерируется исключение STATUS_INVALID_HANDLE. Фактически, проверка корректности операций с описателями в [Application Verifier](http://msdn.microsoft.com/en-us/library/windows/desktop/dd371695(v=vs.85).aspx) - это тонкая обертка вокруг функций трассировки, предоставляемых ядром. Расширение отладчика !htrace - аналогично.

<!--more-->Включение трассировки описателей - отличный способ вычистить код, неаккуратно работающий с описателями. Есть только одна маленькая проблема. Включение трассировки делается для всего процесса сразу. При этом нет никакой (по крайней мере известной мне) возможности выключить генерацию исключений STATUS_INVALID_HANDLE, но оставить ведение журнала операций с описателями. Почему это проблема? Потому, что стоит приложению выбраться за пределы тестовой лабы в реальный мир, как сразу в процесс приложения начинают внедряться все кому не лень. Антивирусы, всяческие песочницы, файерволы (как это ни странно)... Это не говоря о случаях, когда приложение само подгружает плагины. Даже если приложение работает с описателями абсолютно корректно, многие “внедренцы” этим похвастаться не могут, что, при включенной трассировке, равноценно фатальному STATUS_INVALID_HANDLE. Откуда, спрашиваете, я это знаю? (потирает набитую шишку и трогает пожелтевший уже “фонарь” под левым глазом). Да знаю уш!

Один из сценариев, когда включение трассировки без генерации исключений было бы полезно - это отлов чужих DLL, которые по ошибке закрывают не свои описатели. К примеру, передают мусор из неинициализированной памяти в CloseHandle(), который, по стечению обстоятельств, оказывается открытым описателем. По журналу операций, отследить кто закрыл чужой описатель - минутное дело. А дальше, зная кто виноват, можно найти способ нейтрализовать “вредителя”. :-) Но это не работает, если внедренные DLL валят приложение по любому чиху. Пользователям все равно, от чего приложение упало. Их заботит, чтобы оно падало как можно меньше.

Но постойте, скажете вы. Исключение же можно прехватить, а затем продолжить выполнение кода, как будто его и не было. Да, я тоже так думал (потирает еще одну шишку). Для того, чтобы исключение можно было проигноривать, контекст процессора, сохраненный при возбуждении исключения, должен содержать все регистры, необходимые для продолжения работы. В случае с STATUS_INVALID_HANDLE - все non volatile регистры, так как исключение генерируется в недрах системного вызова. Как выяснилось, при STATUS_INVALID_HANDLE не сохраняются, как минимум, ESI и EDI. Оба - очень даже non volatile и должны сохранятся. Вот пример кода, который нормально выполняется только при отключенной трассировке описателей:

```cpp
typedef struct _PROCESS_HANDLE_TRACING_ENABLE_EX {
  ULONG Flags;
  ULONG TotalSlots;
} PROCESS_HANDLE_TRACING_ENABLE_EX, *PPROCESS_HANDLE_TRACING_ENABLE_EX;

const ULONG ProcessHandleTracing = 32;

LONG InvalidHandleFilter(EXCEPTION_POINTERS* info) {
  if (info->ExceptionRecord->ExceptionCode != STATUS_INVALID_HANDLE)
    return EXCEPTION_CONTINUE_SEARCH;

  // Return STATUS_INVALID_HANDLE as the result of a syscall.
  info->ContextRecord->Eax = STATUS_INVALID_HANDLE;
  return EXCEPTION_CONTINUE_EXECUTION;
}

int main(int argc, const char*argv[]) {
  // Enable handle tracing.
  PROCESS_HANDLE_TRACING_ENABLE_EX enable = { 0, 0x20000 };
  NtSetInformationProcess(
      GetCurrentProcess(), ProcessHandleTracing, &enable, sizeof(enable));

  // Probe invalid handles, expecting InvalidHandleFilter() to suppress
  // STATUS_INVALID_HANDLE exceptions.
  for (LONG handle = 0x900; handle < 0x1000; handle += 4) {
    __try {
      printf("handle: 0x%08x, status: 0x%08x\n", handle, status);
      status = ReleaseMutex(reinterpret_cast<HANDLE>(handle));
      printf("handle: 0x%08x, status: 0x%08x\n", handle, status);
    } __except(InvalidHandleFilter(GetExceptionInformation())) {
    }
  }

  return 0;
}
```

Из кода, понятное дело, убраны все проверки ошибок из соображений компактности. Собранный в отладочной конфигурации, этот код на моей машине красиво падает на попытке выполнить код по случайному адресу:

```no-highlight
0:000>0:000> k
(1638.1754): Access violation - code c0000005 (first chance)
First chance exceptions are reported before any exception handling.
This exception may be expected and handled.
eax=00000000 ebx=004b124f ecx=7efdd000 edx=00000006 esi=00000028 edi=00000000
eip=004b124f esp=001dfdf0 ebp=001dfe38 iopl=0         nv up ei pl zr na pe nc
cs=0023  ss=002b  ds=002b  es=002b  fs=0053  gs=002b             efl=00010246
004b124f ba0df0adba      mov     edx,0BAADF00Dh

0:000> k
ChildEBP RetAddr  
001dfdec 013b1130 0x4b124f
001dfe38 013b1383 rabbit!main+0xe0
001dfe7c 75f833aa rabbit!__tmainCRTStartup+0x122
001dfe88 77d89ef2 kernel32!BaseThreadInitThunk+0x12
001dfec8 77d89ec5 ntdll!RtlInitializeExceptionChain+0x63
001dfee0 00000000 ntdll!RtlInitializeExceptionChain+0x36

0:000> u @eip-4
004b124b 3030            xor     byte ptr [eax],dh
004b124d 300a            xor     byte ptr [edx],cl
004b124f ba0df0adba      mov     edx,0BAADF00Dh
004b1254 0df0adba0d      or      eax,0DBAADF0h
004b1259 f0ad            lock lods dword ptr [esi]
004b125b ba0df0adba      mov     edx,0BAADF00Dh
004b1260 0df0adba0d      or      eax,0DBAADF0h
004b1265 f0ad            lock lods dword ptr [esi]
```

Стоит только запретить трасировку, все сразу начинает работать так как надо.
