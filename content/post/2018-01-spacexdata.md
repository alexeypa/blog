---
title: Драконы не летают по средам
date: 2018-01-20T14:17:33-08:00
slug: spacexdata
tags:
 - Plotly
 - SpaceX
---

Я давно подозревал, что SpaceX предпочитает запускать на выходных, а не в
будние дни. Проведя очередную субботу в [Mission Control](
https://upload.wikimedia.org/wikipedia/commons/4/49/SpaceX_Mission_Control_in_Hawthorne%2C_CA.jpg),
я решил проверить, так ли это (ну и за одно немного с javascript поиграться).

Фаны SpaceX составили и продолжают пополнять [базу запусков SpaceX](
https://github.com/r-spacex/SpaceX-API). В базе указывается время запуска, тип
орбиты и масса другой полезной информации. Согласно этой базе получается вот
такая картина:

<div id="launches_by_weekday"></div>

Запуски к МКС обычно происходят в конце недели, а вот на ГПО летают чаще в
начале недели. Вторник оказался самым незапускным днем.

А вот если разбить запуски по времени дня, то получается вот такой расклад:

<div id="launches_by_hour"></div>

Запуски на низкую орбиту обычно идут в первой половине дня, а на ГПО летают все
больше после обеда или в полночь. Время дня здесь - калифорнийское.

Данные для графиков тянутся напрямую с https://api.spacexdata.com, так что
графики будут обновляться по мере пополнения базы.

<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="https://code.jquery.com/jquery-3.3.0.min.js"></script>
<script src="/tz/date.js"></script>
<script src="/2018/01/spacexdata.js"></script>

<!--more-->
