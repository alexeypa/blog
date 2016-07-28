---
author: admin
date: 2007-08-21T16:18:40-07:00
aliases:
- /2007/08/21/224
title: DParser  vs. PLY
slug: 224
tags:
- Win32.Utf8
---

Переделал [разбор С заголовков]({{< relref "post/2007-08-17-первый-блин-комом.md" >}}) на DParser – получил ускорение в 10 раз. Мелочь, а приятно. :-)

![DParser profiling](/2007/08/dparser_profile_output.png)

PS. Под профайлером разница меньше, - раз шесть всего, но тоже впечатляет. 
