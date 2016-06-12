---
author: admin
comments: true
date: 2007-01-09 20:31:52+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2007/01/09/131
slug: windows-home-server
title: Windows Home Server.
wordpress_id: 131
categories:
- itblogs
tags:
- Технологии
- Windows
---

Вчера на [CES](http://www.cesweb.org/default.asp) Билл Гейтс представил [Windows Home Server](http://microsoft.blognewschannel.com/archives/2007/01/07/exclusive-windows-home-server-in-detail/) - операционную систему для домашнего сервера. Это именно то, о чём так долго мечтали большевики (в моем лице). 

<!-- more -->Идея домашнего NAS решения довольно проста: тихий компьютер и урезанная версия операционной системы (обычно - вариант Linux, редко - Windows Server 2003) реализующая базовые сервисы: хранилище файлов, пользователи, резервное копирование, кард-ридеры и т.п. Самосборный вариант обычно представляет собой полноценный компьютер в кладовке. Готовые системы (например, [ReadyNAS](http://www.infrant.com/products/products_details.php?name=ReadyNAS%20NV) или [Cube Station](http://www.synology.com/enu/products/CS406series/index.php)) - тихий кубик под столом.

Вроде всё шоколадно, но есть и проблемы. Существующие готовые системы имеют, с моей точки зрения, один огромный недостаток - отсутствие возможности создать собственный Windows домен на их основе. Нельзя иметь один список пользователей и назначать права доступа на всех машинах в сети. 

С другой стороны самосборные варианты могут обеспечить все нужные сервисы, но при этом с ними слишком много возни. Настройка и администрирование системы, настройка резервного копирования по расписанию, борьба за децибелы...

Решения на основе Windows Home Server должны, теоретически, обладать всеми преимуществами существующих готовых систем и не обладать их недостатками:




	
  * "Кубик под столом" будет достаточно тихим;

	
  * Единый список пользователей упрощает администрирование;

	
  * Резервное копирование в фоне позволяет не думать о его настройке.



Кроме этих трёх пунктов, есть ещё не столь важные для меня: интеграция с Media Center, единое хранилище для e-mail и интеграция с Windows Update Services. В общем, домашний NAS на Windows Home Server уверенно входит в тройку лидеров в качестве подарка на мой день рожденья. Я надеюсь, что к тому времени его можно будет увидеть на полках магазинов.

Ссылки по теме:

	
  * [Windows Home Server In Detail.](http://microsoft.blognewschannel.com/archives/2007/01/07/exclusive-windows-home-server-in-detail/)

	
  * [Windows Home Server!](http://www.geekpulp.co.nz/2007/01/07/windows-home-server/)

	
  * [Windows Home Server.](http://www.madprops.org/cs/blogs/mabster/archive/2007/01/08/Windows-Home-Server.aspx)


