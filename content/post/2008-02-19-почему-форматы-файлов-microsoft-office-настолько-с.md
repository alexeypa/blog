---
author: admin
comments: true
date: 2008-02-19 23:35:54+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2008/02/19/290
slug: почему-форматы-файлов-microsoft-office-настолько-с
title: Почему форматы файлов Microsoft Office настолько сложны?
wordpress_id: 290
categories:
- itblogs
tags:
- Microsoft
- Office
---

Вслед за публикацией [спецификаций, описывающих формат файлов Microsoft Office](http://www.microsoft.com/interop/docs/OfficeBinaryFormats.mspx), Joel Spolsky написал [неплохую статью](http://www.joelonsoftware.com/items/2008/02/19.html), объясняющую почему формат этих файлов настолько сложен и, на первый взгляд, специально запутан до невозможности. 

> A normal programmer would conclude that Office's binary file formats:

>   * are deliberately obfuscated 

>   * are the product of a demented Borg mind 

>   * were created by insanely bad programmers 

>   * and are impossible to read or create correctly. 

Если коротко, то проблема в том, что эти форматы имеют длинную историю и при их разработке преследовались совсем другие цели нежели преследовались бы при разработке формата «офисных» файлов сейчас. Это, кстати, касается и OOXML, так как этот формат по-прежнему должен поддерживать практически все возможности, которые предоставляют бинарные форматы.

Выводы в статье тоже заслуживают внимания. Если вы не пишете клон Microsoft Office (иными словами OpenOffice или StarOffice), то вполне вероятно, что идея реализовать работу с «офисными» форматами в полном объеме не слишком хороша. Вместо этого стоит либо воспользоваться OLE автоматизацией, которую приложения Microsoft Office вполне поддерживают, либо стоит выбрать формат по проще, но, при этом, совместимый с офисом.
