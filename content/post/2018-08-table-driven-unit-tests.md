---
title: Табличные юнит тесты
date: 2018-08-01T19:52:48-07:00
slug: table-driven-unit-tests
tags:
 - Программирование
 - Тестирование
 - Юнит тесты
---

Расскажу об одной технике, которая, как мне кажется, позволяет писать более
понятные и читаемые юнит тесты. Начну немного издалека. Допустим мы хотим
убедится, что определенный кусок кода работает правильно. Если бы мы имели дело
с игрушечным примером, то это наш тест мог бы Примерно вот так:

```cpp
bool foobar(int x, int y)
{
    return (x + y) > 0 && ((x + y) % 3) == 0;
}
```

```cpp
ASSERT_FALSE(foobar(0, 0));
ASSERT_FALSE(foobar(0, 1));
ASSERT_FALSE(foobar(0, 2));
ASSERT_TRUE (foobar(0, 3));
ASSERT_FALSE(foobar(1, 0));
ASSERT_FALSE(foobar(1, 1));
ASSERT_TRUE (foobar(1, 2));
ASSERT_FALSE(foobar(2, 0));
ASSERT_TRUE (foobar(2, 1));
ASSERT_FALSE(foobar(2, 2));
...
```

Такой тест достаточно легко читать. Достаточно понять конструкцию
`ASSERT_XXX(foobar(...))` после чего глаза сами фокусируются на входных
значениях, автоматически отсеивая ненужный синтаксический мусор.

Однако, если взять реальный код, то подобный пример превратиться в гораздо менее
удобочитаемого монстра:

```cpp
std::unique_ptr<Foobar> rabbit =
    create_foobar_with_abc(parent,
        some_context,
        more_stuff + that + is_required + to_create_foobar,
        a,
        b,
        mock_c(),
        logger);

ASSERT_TRUE(
    rabbit->connect(
        this_thing,
        that_key,
        did_you_think_we_are_done_here ? no : hell_no));

ASSERT_TRUE(rabbit->wait_for_accept(timeout));

ASSERT_FALSE(rabbit->foobar(0, 0));
```

... и так далее для каждого тест кейса. Подобный код легко превращается в
длинную простыню однообразного текста с незаметными, но важными вариациями во
входных данных или параметрах инициализации.

<!--more-->

Чтобы сделать этот код более читаемым нужно его разделить на разные по
назначению части: собрать однообразный код инициализации в одном месте, а набор
входных значений для теста - в другом. Например вот так:

```cpp
struct {
    int x;
    int y;
    std::string that_thing;
    std::string this_key;
    bool result;
} const cases[] = {
    {0, 0, "thing1", "key2", false},
    {0, 1, "thing1", "key2", false},
    {0, 2, "thing1", "key2", false},
    {0, 3, "thing1", "key1", true },
    {1, 0, "thing2", "key1", false},
    {1, 1, "thing2", "",     false},
    {1, 2, "thing2", "",     true },
    {2, 0, "",       "",     false},
    {2, 1, "",       "",     true },
    {2, 2, "",       "",     false},
};

for (const auto& c : cases)
{
    std::unique_ptr<Foobar> rabbit =
        create_foobar_with_abc(parent,
            some_context,
            more_stuff + that + is_required + to_create_foobar,
            a,
            b,
            mock_c(),
            logger);

    if (!c.that_thing.empty())
    {
        ASSERT_TRUE(
            rabbit->connect(
                c.this_thing,
                c.that_key,
                did_you_think_we_are_done_here ? no : hell_no));

        ASSERT_TRUE(rabbit->wait_for_accept(timeout));
    }

    ASSERT_EQ(rabbit->foobar(c.x, c.y), c.result);
}
```

Смотрите что получилось. Код инициализации стал сложнее, так так теперь он
поддерживает все варианты инициализации, используемые в тесте. Но его нужно
прочитать только один раз, чтобы понять что происходит. Далее внимание
программиста переключается на таблицу с входными данными, которая полностью
описывает поведение тестируемого кода.

Таблица получается заметно компактнее длинной простыни выше. В идеале она должна
помещаться на один экран. И поскольку таким способом группируются похожие тесты,
читать её очень легко.

Что думаете?
