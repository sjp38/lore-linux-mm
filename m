Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8C95B6B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 06:32:37 -0400 (EDT)
Received: by ioii196 with SMTP id i196so84457589ioi.3
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 03:32:37 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id nv7si10997428igb.3.2015.10.15.03.32.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 03:32:37 -0700 (PDT)
Received: by pabur7 with SMTP id ur7so1856341pab.2
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 03:32:36 -0700 (PDT)
Date: Thu, 15 Oct 2015 19:35:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: don't test shrinker_enabled in
 zs_shrinker_count()
Message-ID: <20151015103454.GA3527@bbox>
References: <1444787879-5428-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20151015022928.GB2840@bbox>
 <20151015035317.GF1735@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151015035317.GF1735@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Thu, Oct 15, 2015 at 12:53:17PM +0900, Sergey Senozhatsky wrote:
> On (10/15/15 11:29), Minchan Kim wrote:
> [..]
> > I'm in favor of removing shrinker disable feature with this patch(
> > although we didn't implement it yet) because if there is some problem
> > of compaction, we should reveal and fix it without hiding with the
> > feature.
> > 
> 
> sure.
> 
> > One thing I want is if we decide it, let's remove all things
> > about shrinker_enabled(ie, variable).
> > If we might need it later, we could introduce it easily.
> 
> well, do we really want to make the shrinker a vital part of zsmalloc?
> 
> it's not that we will tighten the dependency between zsmalloc and
> shrinker, we will introduce it instead. in a sense that, at the moment,
> zsmalloc is, let's say, ignorant to shrinker registration errors
> (shrinker registration implementation is internal to shrinker), because
> there is no direct impact on zsmalloc functionality -- zsmalloc will not
> be able to release some pages (there are if-s here: first, zsmalloc
> shrinker callback may even not be called; second, zsmalloc may not be
> albe to migrate objects and release objects).
> 
> no really strong opinion against, but at the same time zsmalloc will
> have another point of failure (again, zsmalloc should not be aware of
> shrinker registration implementation and why it may fail).
> 
> so... I can prepare a new patch later today.

I misunderstood your description. I thought you wanted to remove
codes for disabling auto-compaction by user because I really don't
want it like same reason of VM's compaction. My bad.

You woke up my brain, I remember the reason.
Thanks.

Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
