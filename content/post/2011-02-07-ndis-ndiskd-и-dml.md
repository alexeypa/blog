---
author: admin
comments: true
date: 2011-02-07 05:19:08+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2011/02/06/972
slug: ndis-ndiskd-и-dml
title: NDIS, !ndiskd и DML.
wordpress_id: 972
categories:
- itblogs
tags:
- Отладка
- NDIS
- Windows
- Windows Kernel
---

На работе понадобилось написать драйвер для сетевой карты. Я этого раньше никогда не делал и вообще с [NDIS](http://msdn.microsoft.com/en-us/library/ms817945.aspx) дела не имел. А тут такая возможность! Делюсь впечатлениями.

В общем и целом NDIS мне понравился. Интерфейсы довольно логичны, хотя и многочисленны. Взаимосвязь между разными компонентами в большинстве случаев после недолгой медитации становится довольно очевидной. Все структуры снабжены заголовком с сигнатурой, версией и размером, что, помимо заботы об обратной совместимости, означает меньше проблем с отладкой. При необходимости нужную структуру можно просто найти в памяти.

Не обошлось и без темного угла в чулане в виде кучи [OID](http://msdn.microsoft.com/en-us/library/ff566713(v=vs.85).aspx)-ов. Их как-то очень много и не совсем понятно, на какие нужно отзываться, а какие можно игнорировать. Не смотря на то, что эта информация в MSDN есть. Сводная табличка, описывающая что нужно, а что нет, не помешала бы. Вроде вот этой: [http://msdn.microsoft.com/en-us/library/ff557139(VS.85).aspx](http://msdn.microsoft.com/en-us/library/ff557139(VS.85).aspx), только по всем OID-ам, сгруппированным по категориям: обязательные для всех, для Ethernet устройств, для TCP/IP Checksum Offloading, отдельно для TCP/IP Chimney Offloading и т.д.

Некоторые структуры запутаны. В том же TCP/IP Checksum Offloading используется несколько разных структур для описания фактически одного и того же: [NDIS_TCP_IP_CHECKSUM_OFFLOAD](http://msdn.microsoft.com/en-us/library/ff567878(VS.85).aspx), [NDIS_OFFLOAD_PARAMETERS](http://msdn.microsoft.com/en-us/library/ff566706(VS.85).aspx), [NDIS_OFFLOAD_ENCAPSULATION](http://msdn.microsoft.com/en-us/library/ff566702(VS.85).aspx).

Порадовало расширение для отладчика, написанное специально для NDIS: !ndiskd. Вот пример вывода информации по загруженным miniport-ам:

[![Пример вывода команды !ndiskd.miniport.](http://blog.not-a-kernel-guy.com/wp-content/uploads/2011/02/ndiskd_miniport.png)](http://blog.not-a-kernel-guy.com/wp-content/uploads/2011/02/ndiskd_miniport.png)

А вот – по конкретному miniport-у:

[![Другой пример вывода команды !ndiskd.miniport.](http://blog.not-a-kernel-guy.com/wp-content/uploads/2011/02/ndiskd_miniport2.png)](http://blog.not-a-kernel-guy.com/wp-content/uploads/2011/02/ndiskd_miniport2.png)

Активно и к месту используется [DML](http://windbg.info/doc/1-common-cmds.html#5_dml). На подсвеченные ссылки можно кликать – расширение выведет более подробную информацию об этом элементе. Более того, к месту выводятся всякие полезные подсказки. Например, вот что выводит !ndiskd.miniport если .sympath не задан:

[![Подсказка про неверно настроенные символы.](http://blog.not-a-kernel-guy.com/wp-content/uploads/2011/02/ndiskd_no_symbols.png)](http://blog.not-a-kernel-guy.com/wp-content/uploads/2011/02/ndiskd_no_symbols.png)

Вообще DML крайне полезная штука. Очень жаль, что он практически не используется.
