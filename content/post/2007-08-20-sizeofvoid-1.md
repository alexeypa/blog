---
author: admin
comments: true
date: 2007-08-20 17:25:28+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2007/08/20/223
slug: sizeofvoid-1
title: sizeof(void) == 1
wordpress_id: 223
categories:
- itblogs
tags:
- C/C++
- Программирование
---

Наткнулся на забавную вещь. Вот такой код спокойно компилируется GCC (версия 3.4.2 (mingw-special)):


    
    <code class="cpp">#include <stdio.h>
    
    int main()
    {
        void* ptr;
        
        printf("sizeof(void): %d\\n", sizeof(void));
        
        ptr = 0;
        printf("before increment: %p\\n", ptr);
        ptr += 1;
        printf("after increment: %p\\n", ptr);
    
        return 0;
    }</code>



<!-- more -->-Wall не генерирует никаких предупреждений. После запуска выдаёт следующее:


    
    <code class="no-highlight">sizeof(void): 1
    before increment: 00000000
    after increment: 00000001</code>



Т.е. sizeof(void) равен единице и инкремент void* указателя работает также как для char*. Visual C++ 2005 на этот код говорит:


    
    <code class="no-highlight">rabbit.c(7) : warning C4034: sizeof returns 0
    rabbit.c(11) : error C2036: 'void *' : unknown size</code>




