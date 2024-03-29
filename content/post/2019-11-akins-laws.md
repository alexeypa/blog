---
title: Законы космической инженерии (Законы Акина)
date: 2019-11-29T11:56:25-08:00
slug: akins_laws
tags:
- Космонавтика
---

[Давид Акин][3], директор лаборатории космических систем на факультете
аэрокосмической инженерии Мерилендского университета собрал список [законов
космической инженерии][1], которые удивительно точно описывают реальность
разработки космических систем. Меня больше всего зацепил вот этот:

> Your best design efforts will inevitably wind up being useless in the final
> design. Learn to live with the disappointment.

> Ваши лучшие наработки в конечном итоге окажутся не нужны. Привыкайте жить с
> разочарованием.

Я как-то потратил несколько недель на оптимизацию кода, формирующего пакеты с
телеметрией, с тем чтобы укорить его в несколько раз и сэкономить 10-15% общего
времени выполнения. Что было очень важно, так как мы в очередной раз вылезли за
допустимое время выполнения. Обложил юнит тестами со всех сторон... На code
review основной претензией к коду было "ну я верю, что это работает, но нельзя
ли как-нибудь попроще?" Через несколько недель я в отпуск пошел, а в том коде
нашли баг... Было интересно и увлекательно.

А вот недавно, я просто удалил одну проверку в двух функциях, и сэкономил те же
10-15%. Результат одинаковый, но затраченные усилия отличаются на два порядка.

Ну и, само-собой, классика:

> Space is a completely unforgiving environment. If you screw up the engineering,
> somebody dies (and there's no partial credit because most of the analysis was
> right...)

> Космос совершенно не прощает ошибок. Если вы ошиблись при разработке - кто-то
> умрет (и вы не получите частичный зачет за то, что большая часть анализа была
> верной)

Список широко цитируется в узких кругах, в том числе на Хабре публиковался
[перевод][2] (правда не на 100% точный, как мне кажется).

<!--more-->

[1]: https://spacecraft.ssl.umd.edu/akins_laws.html
[2]: https://habr.com/ru/post/354936/
[3]: https://aero.umd.edu/clark/faculty/3/David-Akin
