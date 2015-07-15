Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 06F6228027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 07:17:18 -0400 (EDT)
Received: by pacan13 with SMTP id an13so22785936pac.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 04:17:17 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id r12si6989352pdi.246.2015.07.15.04.17.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 04:17:17 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so22693934pac.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 04:17:16 -0700 (PDT)
Date: Wed, 15 Jul 2015 20:16:25 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 0/3] zsmalloc: small compaction improvements
Message-ID: <20150715111625.GC3998@swordfish>
References: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150713233602.GA31822@blaptop.AC68U>
 <20150714003132.GA2463@swordfish>
 <20150714005459.GA12786@blaptop.AC68U>
 <20150714122932.GA597@swordfish>
 <20150714165224.GA384@blaptop>
 <20150715002106.GA742@swordfish>
 <20150715002359.GA29240@blaptop.AC68U>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150715002359.GA29240@blaptop.AC68U>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (07/15/15 09:24), Minchan Kim wrote:
> On Wed, Jul 15, 2015 at 09:21:06AM +0900, Sergey Senozhatsky wrote:
> > On (07/15/15 01:52), Minchan Kim wrote:
> > > > alrighty... again...
> > > > 
> > > > > > 
> > > > > > /sys/block/zram<id>/compact is a black box. We provide it, we don't
> > > > > > throttle it in the kernel, and user space is absolutely clueless when
> > > > > > it invokes compaction. From some remote (or alternative) point of
> > > > > 
> > > > > But we have zs_can_compact so it can effectively skip the class if it
> > > > > is not proper class.
> > > > 
> > > > user triggered compaction can compact too much.
> > > > in its current state triggering a compaction from user space is like
> > > > playing a lottery or a russian roulette.
> > > 
> > > We were on different page.
> > 
> > > I thought the motivation from this patchset is to prevent compaction
> > > overhead by frequent user-driven compaction request because user
> > > don't know how they can get free pages by compaction so they should
> > > ask compact frequently with blind.
> > 
> > this is exactly the motivation for this patchset. seriously.
> 
> User should rely on the auto-compaction.

yep, which will be available in 5-6 months... right behind the corner.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
