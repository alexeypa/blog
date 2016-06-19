---
author: admin
date: 2006-10-23 17:15:36+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2006/10/23/88
slug: история-команд-в-powershell
title: История команд в PowerShell
wordpress_id: 88
tags:
- PowerShell
---

Хозяйке на заметку: глубина истории команд в PowerShell по умолчанию - 64 команды. С помощью $MaximumHistoryCount можно увеличить лимит до максимума в 32767 команд:

```no-highlight
$MaximumHistoryCount = 32767
```
