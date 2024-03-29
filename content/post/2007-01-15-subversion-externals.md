---
author: admin
date: 2007-01-15T15:20:59-07:00
aliases:
- /2007/01/15/134
title: Subversion Externals
slug: 134
tags:
- Инструменты
---

Сегодня, вытягивая исходники WordPress, обратил внимание на такое сообщение:

```no-highlight
...
A    2.0.5\\wp-admin\\edit-form.php
A    2.0.5\\wp-feed.php

Fetching external item into '2.0.5\\wp-content\\plugins\\akismet'
A    2.0.5\\wp-content\\plugins\\akismet\\akismet.gif
A    2.0.5\\wp-content\\plugins\\akismet\\akismet.php
Checked out external at revision 7355.

Checked out revision 4731.
```

Подобного я раньше не видел. Меня, собственно, заинтересовали слова “external item”.  Оказалось, что Subversion позволяет включать в один репозиторий каталоги из других репозиториев. Фактически, Subversion поддерживает символические ссылки между репозиториями. Использование этого механизма может быть удобнее тех маленьких хитростей, про которые я  писал в [предыдущем посте]({{< relref "2006-12-29-контроль-сторонних-библиотек-с-помощ.md" >}}) на эту тему. Особенно в случае, если код внешних библиотек не модифицируется. 

Сам процесс создания ссылок хорошо описывается в svnbook: [Externals Definitions](http://spin.atomicobject.com/2005/10/12/svnexternals/). Там же описываются ограничения и сопутствующие сложности.
