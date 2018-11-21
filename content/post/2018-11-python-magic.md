---
title: Волшебство Питона
date: 2018-11-20T22:36:35-08:00
slug: python-magic
tags:
 - Программирование
 - Python
---

Мне все-таки не понятно как живут большие проекты, написанные на Питоне. Он же
как песок. Пока проект небольшой - все классно. Быстро накидали горку мокрого
песка, лопаткой обхлопали для придания формы и все дела. Знай только что брызгай
водой своевременно. Когда проект разрастается, то красивый и уютный песчанный
замок превращается в минное поле. Отрефакторил подвал - крыша отвалилась.
Поправил крышу - окна слиплись в один комок. 

Непонятно как все это счастье держать в одной куче. Неужели все живут за счет
100% покрытия тестами? Не верю. Или все на PyCharm сидят?

Расскажу про очередной прикол Питона. Итак есть простой код:

```python
def init(factories):
    """Convert a list of factorie into a list of objects.""" 
    return [factory() for factory in factories]

def cleanup(objects):
    """Clean up objects in the reversed order of their creation."""
    for obj in reversed(objects):
        obj.cleanup()
```

`init()` берет список фабрик и отдает список объектов, созданных фабриками.
`cleanup()` чистит созданные объекты в порядке, противоположном порядку
создания. Нам требуется написать тест, который проверяет, что методы `cleanup()`
вызываются в правильном порядке:

```python
from itertools import permutations
import mock

def test_cleanup():
    """Verify cleanup() order."""
    # Try all permitations of initialization order. 
    for init_order in permutations(range(3)):
        cleanup_order = []

        def factory(index):
            def cleanup():
                """Record the clean up order."""
                cleanup_order.append(index)

            def create():
                """Return a mock implementing cleanup()."""
                obj = mock.Mock
                obj.cleanup = mock.Mock(side_effect=cleanup)
                return obj

            return create

        # Create objects in the desired order.
        objects = init([factory(index) for index in init_order])

        cleanup(objects)

        # Verify that the object were cleaned up in the reveresed
        # order of their creation.
        assert cleanup_order == list(reversed(init_order))
```

Разберу логику по кускам. Тест перебирает все возможные кобинации порядка
создания объектов:

```python
for init_order in permutations(range(3)):
```

Декоратор `factory()` возвращает фабрику `create()`, которая в свою учередь
создает объект с методом `cleanup()`. Для создания объекта на коленке
используется [`Mock`][1]. Релизация `cleanup()` запоминает порядок вызова в
`cleanup_order`.

`init()` создает объекты в заданном порядке, `cleanup()` - чистит:

```python
objects = init([factory(index) for index in init_order])

cleanup(objects)
```

Наконец, в самом конце мы проверяем, что порядок очистки противоположен порядку
создания:

```python
assert cleanup_order == list(reversed(init_order))
``` 

Все просто, не так ли? Запускаем тест и получаем облом:

```
>               assert cleanup_order == list(reversed(init_order))
E     assert [2, 2, 2] == [2, 1, 0]
E       At index 1 diff: 2 != 1
E       Use -v to get the full diff


rabbit_test.py:41: AssertionError 
```

Заядлые питонщики давно раскусили, в чем проблема. А вы сможете найти ошибку не
заглядывая в ответ?

<!--more-->

Проблема вот в этой строке:

```python
obj = mock.Mock
```

Здесь `obj` - это не объект класса `mock.Mock`, сам класс `mock.Mock`.
Соответсвенно следующая строка не добавляет метод `cleanup()` к объекту, а
изменяет метод `cleanup()` для всех объектов класса `mock.Mock`. В результате
с моменту вызова `cleanup()`, последняя версия с индексом 2 вызывается для всех
объектов. Если добавить скобки, то все работает как часы:

```python
obj = mock.Mock()
```

Как в таких невыносимых условиях программировать?

[1]: https://docs.python.org/3/library/unittest.mock.html