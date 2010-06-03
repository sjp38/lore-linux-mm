Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DB5B66B0224
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 10:43:40 -0400 (EDT)
Received: by ywh17 with SMTP id 17so161743ywh.1
        for <linux-mm@kvack.org>; Thu, 03 Jun 2010 07:43:35 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 3 Jun 2010 20:13:35 +0530
Message-ID: <AANLkTimHrbAq1Q3Iu3wYGLDdeidYGgy2txaYkYhg5a_x@mail.gmail.com>
Subject: 4-Kb page-size for kernel in ARM-Cortex
From: Uma shankar <shankar.vk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

          It is my understanding that  in ARM, the MMU setting for
kernel VA  range ( 0xc0000000 onwards )
is set up using the section-sized mapping ( 1 Mb in size ) ,  as this
range maps to a  contiguous physical address range.

I am trying out a memory-checking tool on Cortex.    This tool has the
requirement that it  needs to be able to set up  PTE for each 4 Kb
range of  kernel address.

So,  paging_init ( arch/arm/mm/mmu.c ) is modified for this.

But , with this MMU setting,   the kernel hangs somewhere  after
freeing init memory. ( "freeing init mem"  is the last print I see on
console. )

For  3-level page-table setting of kernel VA,  do I have to change
something else also ?

              thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
