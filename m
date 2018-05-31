Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 920196B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 09:10:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z5-v6so12684835pfz.6
        for <linux-mm@kvack.org>; Thu, 31 May 2018 06:10:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o70-v6sor13255484pfo.38.2018.05.31.06.10.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 06:10:28 -0700 (PDT)
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Subject: Can kfree() sleep at runtime?
Message-ID: <30ecafd7-ed61-907b-f924-77fc37dcc753@gmail.com>
Date: Thu, 31 May 2018 21:10:07 +0800
MIME-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------6CDAB3B1D5538EEDBFDCB4E4"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------6CDAB3B1D5538EEDBFDCB4E4
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

I write a static analysis tool (DSAC), and it finds that kfree() can sleep.

Here is the call path for kfree().
Please look at it *from the bottom up*.

[FUNC] alloc_pages(GFP_KERNEL)
arch/x86/mm/pageattr.c, 756: alloc_pages in split_large_page
arch/x86/mm/pageattr.c, 1283: split_large_page in __change_page_attr
arch/x86/mm/pageattr.c, 1391: __change_page_attr in 
__change_page_attr_set_clr
arch/x86/mm/pageattr.c, 2014: __change_page_attr_set_clr in __set_pages_np
arch/x86/mm/pageattr.c, 2034: __set_pages_np in __kernel_map_pages
./include/linux/mm.h, 2488: __kernel_map_pages in kernel_map_pages
mm/page_alloc.c, 1074: kernel_map_pages in free_pages_prepare
mm/page_alloc.c, 1264: free_pages_prepare in __free_pages_ok
mm/page_alloc.c, 4312: __free_pages_ok in __free_pages
mm/slub.c, 3914: __free_pages in kfree

I always have an impression that kfree() never sleeps, so I feel 
confused here.
So could someone please help me to find the mistake?
Thanks in advance :)

Best wishes,
Jia-Ju Bai

--------------6CDAB3B1D5538EEDBFDCB4E4
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<html>
  <head>

    <meta http-equiv="content-type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    Hello,<br>
    <br>
    I write a static analysis tool (DSAC), and it finds that kfree() can
    sleep.
    <br>
    <br>
    Here is the call path for kfree().
    <br>
    Please look at it <b class="moz-txt-star"><span class="moz-txt-tag">*</span>from
      the bottom up<span class="moz-txt-tag">*</span></b>.<br>
    <br>
    [FUNC] alloc_pages(GFP_KERNEL)<br>
    arch/x86/mm/pageattr.c, 756: alloc_pages in split_large_page<br>
    arch/x86/mm/pageattr.c, 1283: split_large_page in __change_page_attr<br>
    arch/x86/mm/pageattr.c, 1391: __change_page_attr in
    __change_page_attr_set_clr<br>
    arch/x86/mm/pageattr.c, 2014: __change_page_attr_set_clr in
    __set_pages_np<br>
    arch/x86/mm/pageattr.c, 2034: __set_pages_np in __kernel_map_pages<br>
    ./include/linux/mm.h, 2488: __kernel_map_pages in kernel_map_pages<br>
    mm/page_alloc.c, 1074: kernel_map_pages in free_pages_prepare<br>
    mm/page_alloc.c, 1264: free_pages_prepare in __free_pages_ok<br>
    mm/page_alloc.c, 4312: __free_pages_ok in __free_pages<br>
    mm/slub.c, 3914: __free_pages in kfree<br>
    <br>
    I always have an impression that kfree() never sleeps, so I feel
    confused here.<br>
    So could someone please help me to find the mistake?<br>
    Thanks in advance :)<br>
    <br>
    Best wishes,<br>
    Jia-Ju Bai<br>
  </body>
</html>

--------------6CDAB3B1D5538EEDBFDCB4E4--
