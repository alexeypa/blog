---
author: admin
comments: true
date: 2008-08-01 05:51:40+00:00
excerpt: None
link: http://blog.not-a-kernel-guy.com/2008/07/31/323
slug: distorm64-disassembler
title: diStorm64 disassembler.
wordpress_id: 323
categories:
- itblogs
tags:
- 64bit
- Disassembler
- Программирование
---

Наткнулся на хороший open source disassembler, понимающий и 80x86 и amd64, и распространяемый под BSD лицензией: [diStorm64](http://www.ragestorm.net/distorm/). 

 

<blockquote>  
> 
> diStorm is a binary stream disassembler. It's capable of disassembling 80x86 instructions in 64 bits (AMD64, X86-64) and both in 16 and 32 bits. In addition, it disassembles FPU, MMX, SSE, SSE2, SSE3, SSSE3, SSE4, 3DNow! (w/ extensions), new x86-64 instruction sets, VMX, and AMD's SVM! diStorm was written to decode quickly every instruction as accurately as possible. Robust decoding, while taking special care for valid or unused prefixes, is what makes this disassembler powerful, especially for research. Another benefit that might come in handy is that the module was written as multi-threaded, which means you could disassemble several streams or more simultaneously.
> 
> </blockquote>

 

В использовании прост как двери: на входе даётся кусок кода, разрядность и его виртуальный адрес, на выходе получается набор инструкций. Для каждой указывается мнемоника, операнды, префиксы и размер. В комплекте идет интерфейсный модуль для Python, что может быть полезно для всяких reverse engineering утилит. 