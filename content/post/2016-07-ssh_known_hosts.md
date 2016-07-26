---
date: 2016-07-25T22:09:50-07:00
publishdate: 2016-07-26T12:00:00-07:00
slug: ssh_known_hosts
tags:
- Chrome
- SSH
title: Как почистить .ssh/known_hosts в Secure Shell
---

Если вы пользуетесь [Secure Shell](https://chrome.google.com/webstore/detail/secure-shell/pnhechapfaindjhompbnflcldabbghjo?hl=en) в Chrome и наткнулись на сообщение об
изменившемся ключе удаленного хоста (скажем после переустановки системы на нем):

[![Secure Shell detects a different ECDSA key](/2016/07/ssh_known_hosts_message_small.png)](/2016/07/ssh_known_hosts_message.png)

... то [вам сюда](https://groups.google.com/a/chromium.org/forum/#!topic/chromium-hterm/XZtSm6P0acw).

В двух словах, чтобы почистить конкретный ключ из ``.ssh/known_hosts``,
выполните следующую команду (заменив ``index`` на номер ключа, указанный в
сообщении об ошибке) в консоли разработчика (Ctrl+Shift+J):

```js
term_.command.removeKnownHostByIndex(index)
```

Для принятия радикальных мер, т.е. для полной очистки ``.ssh/known_hosts``,
можно воспользоваться командой:

```js
term_.command.removeAllKnownHosts()
```

У меня все.

<!--more-->
