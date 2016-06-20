---
author: admin
date: 2011-06-15 06:38:43+00:00
aliases:
- /2011/06/14/1094
title: Функция DeviceIoControlEx
slug: 1094
tags:
- Программирование
- Win32
- Windows
---

Win32 API предоставляет «Ex» варианты функций ReadFile и WriteFile, в то время как «Ex» варианта функции DeviceIoControl не предлагается. Исправить этот недостаток очень просто, так как соответствующая функция Native API документирована в MSDN: [NtDeviceIoControlFile](http://msdn.microsoft.com/en-us/library/ms648411(v=vs.85).aspx) (хотя и помечена как «Deprecated»). Прототип новой функции будет выглядеть вот так:

<!--more-->

```cpp
BOOL
WINAPI
DeviceIoControlEx(
    __in HANDLE hDevice,
    __in DWORD dwIoControlCode,
    __in_opt LPVOID lpInBuffer,
    __in DWORD nInBufferSize,
    __out_opt LPVOID lpOutBuffer,
    __in DWORD nOutBufferSize,
    __inout LPOVERLAPPED lpOverlapped,
    __in_opt LPOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
    );
```

Отличий от DeviceIoControl два: количество прочитанных байт возвращается в структуре OVERLAPPED и есть возможность передать указатель на completion callback (простите за мой французский).

NtDeviceIoControlFile будет вызываться вот так:

```cpp
PIO_STATUS_BLOCK IoStatusBlock = (PIO_STATUS_BLOCK)&lpOverlapped->Internal;
IoStatusBlock->Status = STATUS_PENDING;

NTSTATUS Status =
    NtDeviceIoControlFile(
        hDevice,
        NULL,
        ApcRoutine,
        lpCompletionRoutine,
        IoStatusBlock,
        dwIoControlCode,
        lpInBuffer,
        nInBufferSize,
        lpOutBuffer,
        nOutBufferSize);

if (!NT_SUCCESS(Status))
{
    SetLastError(RtlNtStatusToDosError(Status));
    return FALSE;
}

return TRUE;
```

Часть структуры OVERLAPPED используется как IO_STATUS_BLOCK. Точно также поступают ReadFileEx и WriteFileEx. NTSTATUS коды ошибок транслируются в Win32 аналоги функцией [RtlNtStatusToDosError](http://msdn.microsoft.com/en-us/library/ms680600(VS.85).aspx), которая также документирована в MSDN. Прототипы callback-ов Win32 и Native API отличаются, поэтому используется вспомогательная функция ApcRoutine:

```cpp
VOID
WINAPI
ApcRoutine(
    __in PVOID Context,
    __in PIO_STATUS_BLOCK IoStatusBlock,
    __reserved DWORD Reserved
    )
{
    DWORD BytesTransfered = 0;

    if (NT_SUCCESS(IoStatusBlock->Status))
    {
        BytesTransfered = (DWORD)IoStatusBlock->Information;
    }

    ((LPOVERLAPPED_COMPLETION_ROUTINE)Context)(
        RtlNtStatusToDosError(IoStatusBlock->Status),
        BytesTransfered,
        CONTAINING_RECORD(IoStatusBlock, OVERLAPPED, Internal));
}
```

В результате функция DeviceIoControlEx обладает точно такой же семантикой вызова, как и ReadFileEx, и WriteFileEx.
