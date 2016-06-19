---
author: admin
date: 2006-10-08 06:15:02+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2006/10/07/78
slug: com-marshalling
title: COM marshalling
wordpress_id: 78
tags:
- COM
- Программирование
---

Продолжение истории про [Shortcuts, shell and COM apartments](http://blog.not-a-kernel-guy.com/2006/10/04/76).

Разбираясь с написанием proxy для интерфейса IShellLinkDataList, нашел несколько дельных статей в MSDN. Например, [Standard Marshaling Architecture](http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnesscom/html/chapter5apartments.asp) толково описывает как собственно происходит marshalling во время вызова и какие объекты задействованы при этом. В двух словах всё происходит так:

  1. В процессе получения указателя на интерфейс объекта, COM/RPC библиотека проверяет находится ли запрашиваемый объект в том же apartment, что и клиентский код. Если это не так, то создается специальный объект - Stub Manager, который занимается обслуживанием всех удаленных запросов к этому объекту. Для самого объекта Stub Manager выглядит как обычный клиент, находящийся в том же самом apartment.

  2. На стороне клиента создается Proxy Manager. В случае если клиент запрашивает IUnknown, на этом процесс заканчивается. Клиент получает IUnknown, указывающий на сам Proxy Manager. При этом IUnknown::AddRef и IUnknown::Release изменяют значение локального счетчика.

  3. В случае если клиент запрашивает не IUnknown, Proxy Manager создает объект ответственный за marshalling (Marshalling Object) запрошенного интерфейса. CLSID этого объекта хранится в ключе "HKCR\Interface\{interface GUID}\ProxyStubClsid32". Этот объект должен реализовывать стандартный интерфейс IPSFactoryBuffer. Используя IPSFactoryBuffer::CreateProxy Proxy Manager создает объект Interface Proxy, реализующий нужный интерфейс, и возвращает указатель на запрашиваемый интерфейс клиенту.

  4. Когда клиент, используя полученный указатель, вызывает какой-либо из методов объекта , он, на самом деле, вызывает метод Interface Proxy. Interface Proxy пакует переданные параметры в формате протокола Network Data Representation (NDR) и посылает полученный пакет с помощью метода IRpcChannelBuffer::SendReceive. (Указатель на IRpcChannelBuffer Interface Proxy получает в процессе создания)

  5. Получив пакет, Stub Manager точно так же как Proxy Manager создает Marshalling Object, а затем создаёт объект Interface Stub с помощью метода IPSFactoryBuffer::CreateStub. Interface Stub реализует интерфейс IRpcStubBuffer. Stub Manager передает полученный пакет в IRpcStubBuffer::Invoke, который распаковывает переданные параметры и, наконец, вызывает нужный метод объекта.

  6. После того, как управление возвращается в IRpcStubBuffer::Invoke, возвращаемое значение и параметры, помеченные атрибутом [out], упаковываются в пакет и передаются обратно на сторону клиента.

  7. Interface Proxy получает ответ, извлекает из него возвращаемое значение и параметры и передаёт управление клиенту

Из всех объектов, перечисленных выше, разработчику интерфейса необходимо реализовать только Interface Proxy, Interface Stub и Marshalling Object. Proxy Manager, Stub Manager и все остальные объекты реализованы стандартной COM/RPC библиотекой. Более того, в большинстве случаев весь marshalling код генерируется автоматически из описания интерфейсов в IDL. Во время компиляции, MIDL генерирует файлы dlldata.c, xxx_i.c и xxx_p.c, которые можно увидеть в стандартном ATL проекте, сгенерированном в Visual Studio.

К сожалению, в случае с интерфейсом IShellLinkDataList видимо придется писать весь marshalling вручную, поскольку спецификация интерфейса, похоже, не очень-то совместима с RPC. В частности IShellLinkDataList::CopyDataBlock возвращает структуру переменного размера, которая должна освобождаться клиентом с помощью вызова функции LocalFree. Sic!
