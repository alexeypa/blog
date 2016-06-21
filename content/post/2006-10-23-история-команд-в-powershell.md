---
author: admin
date: 2006-10-23T10:15:36-07:00
aliases:
- /2006/10/23/88
title: История команд в PowerShell
slug: 88
tags:
- PowerShell
---

Хозяйке на заметку: глубина истории команд в PowerShell по умолчанию - 64 команды. С помощью $MaximumHistoryCount можно увеличить лимит до максимума в 32767 команд:

```no-highlight
$MaximumHistoryCount = 32767
```
