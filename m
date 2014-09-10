Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 23FA76B0055
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 14:50:45 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id rl12so6633719iec.10
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:50:44 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id cz20si2770313igc.10.2014.09.10.11.50.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 11:50:44 -0700 (PDT)
Received: by mail-ig0-f172.google.com with SMTP id h15so7056712igd.5
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:50:44 -0700 (PDT)
Date: Wed, 10 Sep 2014 11:50:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/compaction: Fix warning of 'flags' may be used
 uninitialized
In-Reply-To: <1410329540-40708-1-git-send-email-Li.Xiubo@freescale.com>
Message-ID: <alpine.DEB.2.02.1409101149500.27173@chino.kir.corp.google.com>
References: <1410329540-40708-1-git-send-email-Li.Xiubo@freescale.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiubo Li <Li.Xiubo@freescale.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, linux-mm@kvack.org

On Wed, 10 Sep 2014, Xiubo Li wrote:

> C      mm/compaction.o
> mm/compaction.c: In function isolate_freepages_block:
> mm/compaction.c:364:37: warning: flags may be used uninitialized in
> this function [-Wmaybe-uninitialized]
>        && compact_unlock_should_abort(&cc->zone->lock, flags,
>                                      ^
> In file included from include/linux/irqflags.h:15:0,
>                  from ./arch/arm/include/asm/bitops.h:27,
>                  from include/linux/bitops.h:33,
>                  from include/linux/kernel.h:10,
>                  from include/linux/list.h:8,
>                  from include/linux/preempt.h:10,
>                  from include/linux/spinlock.h:50,
>                  from include/linux/swap.h:4,
>                  from mm/compaction.c:10:
> mm/compaction.c: In function isolate_migratepages_block:
> ./arch/arm/include/asm/irqflags.h:152:2: warning: flags may be used
> uninitialized in this function [-Wmaybe-uninitialized]
>   asm volatile(
>   ^
> mm/compaction.c:576:16: note: flags as declared here
>   unsigned long flags;
>                 ^
> 
> Signed-off-by: Xiubo Li <Li.Xiubo@freescale.com>

Arnd Bergmann already sent a patch for this to use uninitialized_var() 
privately but it didn't get cc'd to any mailing list, sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
