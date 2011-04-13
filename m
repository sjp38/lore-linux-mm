Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DA8CA900087
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 07:44:42 -0400 (EDT)
Received: by pwi10 with SMTP id 10so304205pwi.14
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 04:44:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <530486.50523.qm@web162020.mail.bf1.yahoo.com>
References: <1302662256.2811.27.camel@edumazet-laptop>
	<530486.50523.qm@web162020.mail.bf1.yahoo.com>
Date: Wed, 13 Apr 2011 19:44:39 +0800
Message-ID: <BANLkTi=7KHMA_JOwQcMQj5M+XU=qO07s2g@mail.gmail.com>
Subject: Re: Regarding memory fragmentation using malloc....
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

On Wed, Apr 13, 2011 at 2:54 PM, Pintu Agarwal <pintu_agarwal@yahoo.com> wrote:
> Dear All,
>
> I am trying to understand how memory fragmentation occurs in linux using many malloc calls.
> I am trying to reproduce the page fragmentation problem in linux 2.6.29.x on a linux mobile(without Swap) using a small malloc(in loop) test program of BLOCK_SIZE (64*(4*K)).
> And then monitoring the page changes in /proc/buddyinfo after each operation.
> From the output I can see that the page values under buddyinfo keeps changing. But I am not able to relate these changes with my malloc BLOCK_SIZE.
> I mean with my BLOCK_SIZE of (2^6 x 4K ==> 2^6 PAGES) the 2^6 th block under /proc/buddyinfo should change. But this is not the actual behaviour.
> Whatever is the blocksize, the buddyinfo changes only for 2^0 or 2^1 or 2^2 or 2^3.
>
> I am trying to measure the level of fragmentation after each page allocation.
> Can somebody explain me in detail, how actually /proc/buddyinfo changes after each allocation and deallocation.
>

What malloc() sees is virtual memory of the process, while buddyinfo
shows physical memory pages.

When you malloc() 64K memory, the kernel may not allocate a 64K
physical memory at one time
for you.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
