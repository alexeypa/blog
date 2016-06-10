---
author: admin
comments: true
date: 2010-07-23 17:19:20+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2010/07/23/861
slug: 64-bit-explained
title: 64 Bit Explained
wordpress_id: 861
categories:
- itblogs
tags:
- Wow64
---

Вот. [Истинная правда](http://piers7.blogspot.com/2010/07/64-bit-explained.html):



<blockquote>Look, it’s really not that hard.

Programs are still in the same place, in %ProgramFiles%, unless you need the 32 bit version, which is in %ProgramFiles(x86)%, except on a 32 bit machine, where it’s still %ProgramFiles%.

All those dll’s are still in %SystemRoot%\System32, just now they’re 64 bit. The 32 bit ones, they’re in %SystemRoot%\SysWOW64. You’re with me so far, right? Oh, and the 16 bit ones are still in %SystemRoot%\System – moving them would just be weird.

Registry settings are in HKLM\Software, unless you mean the settings for the 32 bit programs, in which case they’re in HKLM\Software\Wow6432Node.

So the rule is easy: stick to the 64 bit versions of apps, and you’ll be fine. Apps without a 64 bit version are pretty obscure anyway, Office and Visual Studio for example[1]. Oh, and stick to the 32 bit version of Internet Explorer (which is the default) if you want any of your add-ins to work. The ‘default’ shortcut for everything else is the 64 bit version. Having two shortcuts to everything can be a bit confusing, so sometimes (cmd.exe) there’s only the one (64 bit) and you’ll have to find the other yourself (back in SysWOW64, of course). And don’t forget to ‘Set-ExecutionPolicy RemoteSigned’ in both your 64 bit and 32 bit PowerShell environments.

Always install 64 bit versions of drivers and stuff, unless there isn’t one (MSDORA, JET), or you need both the 32 bit and 64 bit versions (eg to use SMO / SqlCmd from a 32 bit process like MSBuild). Just don’t do this if the 64 bit installer already installs the 32 bit version for you (like Sql Native Client).

Anything with a ‘32’ is for 64 bit. Anything with a ‘64’ is for 32 bit. Except %ProgramW6432% which is the 64 bit ProgramFiles folder in all cases (well, except on a 32 bit machine). Oh and the .net framework didn’t actually move either, but now it has a Framework64 sibling.

I really don’t understand how people get so worked up over it all.</blockquote>



Для всего этого счастья есть [логичное объяснение](http://blog.not-a-kernel-guy.com/2007/06/26/203), сдобренное обычным "ну здесь мы применили маленький хак". Но от этого не сильно легче.

Отсюда: [http://piers7.blogspot.com/2010/07/64-bit-explained.html](http://piers7.blogspot.com/2010/07/64-bit-explained.html).


