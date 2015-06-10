Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 59D846B0070
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 20:07:31 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so22653097pab.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 17:07:31 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id il2si10914569pbc.120.2015.06.09.17.07.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 17:07:30 -0700 (PDT)
Received: by pacyx8 with SMTP id yx8so22724496pac.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 17:07:30 -0700 (PDT)
Date: Wed, 10 Jun 2015 09:07:55 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCHv2 0/8] introduce automatic pool compaction
Message-ID: <20150610000755.GB596@swordfish>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150610000453.GB13376@bgram>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150610000453.GB13376@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello,

On (06/10/15 09:04), Minchan Kim wrote:
> Hello Sergey,
> 
> Thanks for looking this and sorry for the delay for review.
> I don't have a time to hold a review yet.
> Please wait and I try to get a time within this week.
> 
> Thanks for your patience.

sure, no problem at all.

	-ss

> On Fri, Jun 05, 2015 at 09:03:50PM +0900, Sergey Senozhatsky wrote:
> > Hello,
> > 
> > This patch set tweaks compaction and makes it possible to trigger
> > pool compaction automatically when system is getting low on memory.
> > 
> > zsmalloc in some cases can suffer from a notable fragmentation and
> > compaction can release some considerable amount of memory. The problem
> > here is that currently we fully rely on user space to perform compaction
> > when needed. However, performing zsmalloc compaction is not always an
> > obvious thing to do. For example, suppose we have a `idle' fragmented
> > (compaction was never performed) zram device and system is getting low
> > on memory due to some 3rd party user processes (gcc LTO, or firefox, etc.).
> > It's quite unlikely that user space will issue zpool compaction in this
> > case. Besides, user space cannot tell for sure how badly pool is
> > fragmented; however, this info is known to zsmalloc and, hence, to a
> > shrinker.
> > 
> > v2:
> > -- use a slab shrinker instead of triggering compaction from zs_free (Minchan)
> > 
> > Sergey Senozhatsky (8):
> >   zsmalloc: drop unused variable `nr_to_migrate'
> >   zsmalloc: partial page ordering within a fullness_list
> >   zsmalloc: lower ZS_ALMOST_FULL waterline
> >   zsmalloc: always keep per-class stats
> >   zsmalloc: introduce zs_can_compact() function
> >   zsmalloc: cosmetic compaction code adjustments
> >   zsmalloc/zram: move `num_migrated' to zs_pool
> >   zsmalloc: register a shrinker to trigger auto-compaction
> > 
> >  drivers/block/zram/zram_drv.c |  12 +--
> >  drivers/block/zram/zram_drv.h |   1 -
> >  include/linux/zsmalloc.h      |   1 +
> >  mm/zsmalloc.c                 | 228 +++++++++++++++++++++++++++---------------
> >  4 files changed, 152 insertions(+), 90 deletions(-)
> > 
> > -- 
> > 2.4.2.387.gf86f31a
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
