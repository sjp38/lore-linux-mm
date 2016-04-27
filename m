Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 576CB6B025E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 19:52:45 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id u2so114934583obx.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 16:52:45 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id p63si12801596iod.206.2016.04.27.16.52.43
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 16:52:44 -0700 (PDT)
Date: Thu, 28 Apr 2016 08:54:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 00/13] Support non-lru page migration
Message-ID: <20160427235413.GA19222@bbox>
References: <1461743305-19970-1-git-send-email-minchan@kernel.org>
 <20160427132035.e96f99f3420c8fb0020b0fc4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160427132035.e96f99f3420c8fb0020b0fc4@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, dri-devel@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, John Einar Reitan <john.reitan@foss.arm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Aquini <aquini@redhat.com>, Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, virtualization@lists.linux-foundation.org, Gioh Kim <gi-oh.kim@profitbricks.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Sangseok Lee <sangseok.lee@lge.com>, Kyeongdon Kim <kyeongdon.kim@lge.com>, Chulmin Kim <cmlaika.kim@samsung.com>

Hello Andrew,

On Wed, Apr 27, 2016 at 01:20:35PM -0700, Andrew Morton wrote:
> On Wed, 27 Apr 2016 16:48:13 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > Recently, I got many reports about perfermance degradation in embedded
> > system(Android mobile phone, webOS TV and so on) and easy fork fail.
> > 
> > The problem was fragmentation caused by zram and GPU driver mainly.
> > With memory pressure, their pages were spread out all of pageblock and
> > it cannot be migrated with current compaction algorithm which supports
> > only LRU pages. In the end, compaction cannot work well so reclaimer
> > shrinks all of working set pages. It made system very slow and even to
> > fail to fork easily which requires order-[2 or 3] allocations.
> > 
> > Other pain point is that they cannot use CMA memory space so when OOM
> > kill happens, I can see many free pages in CMA area, which is not
> > memory efficient. In our product which has big CMA memory, it reclaims
> > zones too exccessively to allocate GPU and zram page although there are
> > lots of free space in CMA so system becomes very slow easily.
> > 
> > To solve these problem, this patch tries to add facility to migrate
> > non-lru pages via introducing new functions and page flags to help
> > migration.
> 
> I'm seeing some rejects here against Mel's changes and our patch
> bandwidth is getting waaay way ahead of our review bandwidth.  So I
> think I'll loadshed this patchset at this time, sorry.

I expected the conflict with Mel's change in recent mmotm but doesn't want
to send patches against recent mmotm because it has several problems in
compaction so my test was really trobule.
I just picked patches from Hugh and Vlastimil and finally can test on it.
Anyway, I will rebase my patches on recent mmotm, hoping you picked every
patches on compaction part and respin after a few days.

Thanks for let me knowing your plan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
