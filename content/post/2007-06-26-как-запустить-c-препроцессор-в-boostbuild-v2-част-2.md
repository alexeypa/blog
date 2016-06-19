---
author: admin
date: 2007-06-26 05:52:09+00:00
link: http://blog.not-a-kernel-guy.com/2007/06/25/202
slug: как-запустить-c-препроцессор-в-boostbuild-v2-част-2
title: Как запустить C препроцессор в Boost.Build V2. Часть последняя
wordpress_id: 202
tags:
- Boost.Build
- Инструменты
---

> [В таком виде генератор уже пригоден к использованию, однако его можно сделать ещё лучше. Как - читайте в следующей части.](http://blog.not-a-kernel-guy.com/2007/06/11/197)

Если сравнить исходный код нашего генератора с реализацией генератора объектных файлов в “boost/tools/build/v2/tools/msvc.jam” можно обнаружить несколько отличий:

```python
# Каждое преобразование (C -> OBJ и C++ -> OBJ) требует регистрации собственного
# генератора.
generators.register-c-compiler msvc.compile.c++ : CPP : OBJ : <toolset>msvc ;
generators.register-c-compiler msvc.compile.c : C : OBJ : <toolset>msvc ;

...

# Макроподстановка вида "@(<filename>:E=xxx)" раскрывается в имя файла, в который 
# записывается строка "xxx".
actions compile-c-c++
{
    $(.CC) @"@($(<[1]:W).rsp:E="$(>[1]:W)" -Fo"$(<[1]:W)" -Yu"$(>[3]:D=)" -Fp"$(>[2]:W)" $(CC_RSPLINE))" $(.CC.FILTER)
}

# В CC_RSPLINE формируется командную строка для вызова компилятора.
rule get-rspline ( target : lang-opt )
{
    CC_RSPLINE on $(target) = [ on $(target) return $(lang-opt) -U$(UNDEFS) $(CFLAGS) $(C++FLAGS) $(OPTIONS) -c $(nl)-D$(DEFINES) $(nl)\"-I$(INCLUDES)\" ] ;
}

rule compile.c ( targets + : sources * : properties * )
{
    C++FLAGS on $(targets[1]) = ;
    get-rspline $(targets) : -TC ;
    compile-c-c++ $(<) : $(>) [ on $(<) return $(PCH_FILE) ] [ on $(<) return $(PCH_HEADER) ] ;
}

rule compile.c++ ( targets + : sources * : properties * )
{
    get-rspline $(targets) : -TP ;
    compile-c-c++ $(<) : $(>) [ on $(<) return $(PCH_FILE) ] [ on $(<) return $(PCH_HEADER) ] ;
}
```

Во-первых, генератор из “msvc.jam” различает С и C++ файлы. Сделать это легко – достаточно зарегистрировать два генератора. Вызывающие два разных правила, которые и сформируют нужную командную строку. Впрочем, в случае Visual C++ вся разница заключается в одном флаге -TC или -TP, поэтому правила “compile.c” и “compile.c++” делегируют всю работу общему для C и C++ правилу “compile-c-c++”.

Во-вторых, командная строка, которую формирует стандартный генератор, немного сложнее. Для её формирования используется вспомогательное правило “get-rspline”. Очевидно, что для вызова препроцессору должны передаваться те же самые параметры, которые передаются компилятору. Иными словами, наш генератор должен также использовать правило “get-rspline”.

В-третьих, для формирования командной строки используется встроенная поддержка response файлов (макроподстаповка вида "@(<filename>:E=xxx)"). Большинство опций компилятора перенаправляется в response файл, снижая тем самым вероятность переполнения буфера командной строки.

С учётом этих изменений финальная версия генератора будет выглядеть вот так:

```python
# Импортируем нужные модули
import generators ;
import msvc ;
import toolset ;
import type ;

# Регистрируем новый тип файла. "I" - имя типа, "i" - расширение файла
type.register I : i ;

# Регистрируем генераторы для преобразования C -> OBJ и C++ -> OBJ
generators.register-standard pp.compile.c : C : I ;
generators.register-standard pp.compile.c++ : CPP : I ;

# Импортируем флаги из msvc
toolset.inherit-flags pp : msvc ;

rule compile.c ( targets + : sources * : properties * )
{
    C++FLAGS on $(targets[1]) = ;
    msvc.get-rspline $(targets) : -TC ;
    compile-c-c++ $(<) : $(>) ;
}

rule compile.c++ ( targets + : sources * : properties * )
{
    msvc.get-rspline $(targets) : -TP ;
    compile-c-c++ $(<) : $(>) ;
}

# Команды, непосредственно работающие с файлами
actions compile-c-c++
{
    $(.CC) /EP @"@($(<[1]:W).rsp:E="$(>[1]:W)" $(CC_RSPLINE))" > "$(<[1]:W)"
}
```

Замечу, что этот код не полностью повторяет код из “msvc.jam”. Например, убрано всё имеющее отношение к поддержке предкомпилированных заголовков (precompiled headers, PCH).

Также добавлю, что, не смотря на все достоинства, такого генератора он обладает одним существенным недостатком, - он работает только с Visual C++. Поддержка других компиляторов потребует написания для них своих версий генератора. 
