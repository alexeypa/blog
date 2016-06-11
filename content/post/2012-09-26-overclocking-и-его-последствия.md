---
author: admin
comments: true
date: 2012-09-26 06:01:23+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2012/09/25/1417
slug: overclocking-и-его-последствия
title: Overclocking и его последствия.
wordpress_id: 1417
categories:
- itblogs
tags:
- Отладка
- Программирование
- Юмор
---

А сегодня мы с вами прослушаем лекцию о том, как избежать появления растительности на ладонях и чем её потом выводить...



Разбор crash dump-ов твоего приложения, собранных с пользовательских машин - занятие и увлекательное, и поучительное. Поучительное не столько потому, что демонстрирует твои собственные успехи во всей красе, но потому что не менее красиво показывает достижения других. Одновременно испытываешь и неловкость за содеянное (нахомутал, чего уж там) и гордость (да не так уж и нахомутал - посмотрите, как другие отличились), и облегчение (все одим миром мазаны). А сегодня мы разберем одно из часто встречающихся явлений - overclocking.

<!-- more -->Надо сказать, что раньше эта тема освещалась не так широко, как сейчас. Более того, разговоры на эту тему считались чем-то неприличным и даже - постыдным. Но обилие современной литературы открыло нам глаза. Оказалось, что этим, так или иначе, занимаются практически все, или, по крайней мере, очень многие. Даже целомудренные девицы, которые даже слово “джампер” никогда не слышали, и те, как оказалось, задирают, простите за вульгарность, коеффициент умножения только так. Более того, немало исследований, проведенных британскими учеными, показало, что подобное рукоблудие, в умеренных количествах, не только не опасно, но даже имеет небольшой положительный эффект - ускоряя загрузку Facebook на 0.1%.

Тем не менее чрезмерное увлечение подобным, как выясняется, не так уж безобидно, как может показаться на первый взгляд. Возьмем свежий пример. Пять падений в одном и том же месте:



```no-highlight
remoting_me2me_host!net::URLRequestHttpJob::RecordTimer+0x1f
remoting_me2me_host!net::URLRequestHttpJob::OnStartCompleted+0x24
remoting_me2me_host!base::internal::Invoker<1,base::internal::BindState<base::internal::RunnableAdapter<void (__thiscall net::ProxyService::*)(int)>,void __cdecl(net::ProxyService *,int),void __cdecl(base::internal::UnretainedWrapper<net::ProxyService>)>,void __cdecl(net::ProxyService *,int)>::Run+0x17
remoting_me2me_host!net::HttpNetworkTransaction::DoCallback+0x27
...
```



Так, что у нас в exception record?



```no-highlight
ExceptionAddress: 006969ee (remoting_me2me_host!net::URLRequestHttpJob::RecordTimer+0x0000001f)
   ExceptionCode: c0000005 (Access violation)
  ExceptionFlags: 00000000
NumberParameters: 2
   Parameter[0]: 00000000
   Parameter[1]: 8b571d14
Attempt to read from address 8b571d14
```



Ага, значит хотим прочитать адрес 0x8b571d14. А откуда взялся этот адрес?



```no-highlight
remoting_me2me_host!net::URLRequestHttpJob::RecordTimer+1f 
006969ee 0b8654020000    or      eax,dword ptr [esi+254h]
```



Очень странно. А ведь ESI отлично сохранился в context record:



```no-highlight
0:003> r esi
Last set context:
esi=01246fd8
```



Из 0x01246fd8 + 0x254 совсем никак не получается 0x8b571d14... Ага, а вот и диагноз:



```no-highlight
EXCEPTION_DOESNOT_MATCH_CODE:  This indicates a hardware error.
Instruction at 006969ee does not read/write to 8b571d14
```



Действительно, все пять дампов пришли с одной и той же машины. Все пять описывают идентичние падение при попытке чтения адреса 0x8b571d14, которому, по логике вещей, неоткуда было взяться. И все пять дампов сгенерированы в течение одной минуты.

Завершает анамнез шестой дамп с той же машины, показывающий не менее интересное падение в другом месте:



```no-highlight
0xfe4040f0
remoting_me2me_host!net::internal::`anonymous namespace'::AddLocalhostEntries+0x27b
remoting_me2me_host!net::internal::DnsConfigServiceWin::HostsReader::DoWork+0x44 remoting_me2me_host!net::SerialWorker::DoWorkJob+0xe
...
```



Интересно, откуда взялся этот адрес? А вот откуда - предыдущая инструкция пыталась выполнить переход на адрес 0x004040f0, а попала - на 0xfe4040f0.



```no-highlight
call    remoting_me2me_host!std::basic_string<wchar_t,std::char_traits<wchar_t>,std::allocator<wchar_t> >::assign (004040f0)
```



Шестой дамп был последним присланным с этой машины. То ли, владелец её разочаровался в нашем софте, то ли к вечеру похолодало - не известно.

К этому моменту, думаю, что всем уже стало понятно, что практикуя рекреационный overclocking, следует помнить о мерах предосторожности. Почистите кулер, прогоните кота, и самое главное, - не перегибайте палку. Она вам еще пригодится.

