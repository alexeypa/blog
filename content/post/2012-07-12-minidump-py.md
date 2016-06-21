---
author: admin
date: 2012-07-12T08:51:50-07:00
aliases:
- /2012/07/12/1393
title: minidump.py
slug: 1393
tags:
- Отладка
---

Если вам вдруг зачем-то понадобилось проанализировать структуру минидампа не загружая его в отладчик, начните вот с этой статьи: [http://moyix.blogspot.com/2008/05/parsing-windows-minidumps.html](http://moyix.blogspot.com/2008/05/parsing-windows-minidumps.html). Автор написал [скрипт на Python](http://kurtz.cs.wesleyan.edu/~bdolangavitt/memory/minidumps/minidump.py) (на основе [Construct](http://construct.wikispaces.com)) для анализа дампов, который распознает все потоки, описанные на MSDN (а также недокументированный поток, хранящий информацию об описателях окон).

PS. Скрипт открывает дамп в текстовом режиме, что очевидно не будет работать на Windows. Чтобы этого не случилось, последняя строчка скипта должна выглядеть вот так:

```python
print MINIDUMP_HEADER.parse_stream(open(sys.argv[1], "rb"))
```
