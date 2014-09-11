Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2B92B6B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 05:02:09 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id b8so11214609lan.39
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 02:02:08 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id yl9si457835lbb.21.2014.09.11.02.02.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Sep 2014 02:02:07 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] mm/compaction: Fix warning of 'flags' may be used uninitialized
Date: Thu, 11 Sep 2014 11:02 +0200
Message-ID: <5158230.WXIduiXq5W@wuerfel>
In-Reply-To: <alpine.DEB.2.02.1409101149500.27173@chino.kir.corp.google.com>
References: <1410329540-40708-1-git-send-email-Li.Xiubo@freescale.com> <alpine.DEB.2.02.1409101149500.27173@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Xiubo Li <Li.Xiubo@freescale.com>, Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, linux-mm@kvack.org

On Wednesday 10 September 2014 11:50:41 David Rientjes wrote:
> On Wed, 10 Sep 2014, Xiubo Li wrote:
> 
> > C      mm/compaction.o
> > mm/compaction.c: In function isolate_freepages_block:
> > mm/compaction.c:364:37: warning: flags may be used uninitialized in
> > this function [-Wmaybe-uninitialized]
> >        && compact_unlock_should_abort(&cc->zone->lock, flags,
> >                                      ^
> > In file included from include/linux/irqflags.h:15:0,
> >                  from ./arch/arm/include/asm/bitops.h:27,
> >                  from include/linux/bitops.h:33,
> >                  from include/linux/kernel.h:10,
> >                  from include/linux/list.h:8,
> >                  from include/linux/preempt.h:10,
> >                  from include/linux/spinlock.h:50,
> >                  from include/linux/swap.h:4,
> >                  from mm/compaction.c:10:
> > mm/compaction.c: In function isolate_migratepages_block:
> > ./arch/arm/include/asm/irqflags.h:152:2: warning: flags may be used
> > uninitialized in this function [-Wmaybe-uninitialized]
> >   asm volatile(
> >   ^
> > mm/compaction.c:576:16: note: flags as declared here
> >   unsigned long flags;
> >                 ^
> > 
> > Signed-off-by: Xiubo Li <Li.Xiubo@freescale.com>
> 
> Arnd Bergmann already sent a patch for this to use uninitialized_var() 
> privately but it didn't get cc'd to any mailing list, sorry.

Oops, I hadn't noticed that I missed the mailing lists, sorry about that.
For reference, see my patch below.

	Arnd

8<------
