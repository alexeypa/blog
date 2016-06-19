---
author: admin
comments: true
date: 2012-07-12 15:51:50+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2012/07/12/1393
slug: minidump-py
title: minidump.py
wordpress_id: 1393
categories:
- itblogs
tags:
- Отладка
---

Если вам вдруг зачем-то понадобилось проанализировать структуру минидампа не загружая его в отладчик, начните вот с этой статьи: [http://moyix.blogspot.com/2008/05/parsing-windows-minidumps.html](http://moyix.blogspot.com/2008/05/parsing-windows-minidumps.html). Автор написал [скрипт на Python](http://kurtz.cs.wesleyan.edu/~bdolangavitt/memory/minidumps/minidump.py) (на основе [Construct](http://construct.wikispaces.com)) для анализа дампов, который распознает все потоки, описанные на MSDN (а также недокументированный поток, хранящий информацию об описателях окон).

PS. Скрипт открывает дамп в текстовом режиме, что очевидно не будет работать на Windows. Чтобы этого не случилось, последняя строчка скипта должна выглядеть вот так:

```python
print MINIDUMP_HEADER.parse_stream(open(sys.argv[1], "rb"))
```
