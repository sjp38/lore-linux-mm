Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3F4FF6B006A
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 00:59:17 -0400 (EDT)
Received: by iwn2 with SMTP id 2so600116iwn.14
        for <linux-mm@kvack.org>; Wed, 07 Jul 2010 21:59:15 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 8 Jul 2010 10:29:15 +0530
Message-ID: <AANLkTikYX5U8eoMx5CDh00EVfVXDfO5eslYZ7DSB9zIe@mail.gmail.com>
Subject: Ramzswap :swap-device write failure under low memory
From: Uma shankar <shankar.vk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

 When using ramzswap,  the internal allocator (xvMalloc)  will  try to
grow the pool,
when the compressed block will not fit in any of the existing free chunk.
This memory allocation can fail  under low memory.

This will be informed to the kernel as  a "device write" failure. The
page which was being written will
not be reclaimed, but the kernel will  continue to  try swap out of
other pages ( as kernel
thinks that swap has free space. )

Wont this lead  to the reclaim code ( kswapd  or the direct reclaim
path )  hogging  the processor for some time
before  OOM is finally announced ?

Has  any one  analysed this scenario ?

                    thanks
                     shankar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
