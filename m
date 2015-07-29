Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 70DAE6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:25:07 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so23754711wib.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 05:25:07 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id j10si7169316wjf.167.2015.07.29.05.25.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 05:25:05 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 879D898A45
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 12:25:04 +0000 (UTC)
Date: Wed, 29 Jul 2015 13:25:02 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 08/10] mm, page_alloc: Remove MIGRATE_RESERVE
Message-ID: <20150729122502.GB19352@techsingularity.net>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-9-git-send-email-mgorman@suse.com>
 <55B8A3F3.6090107@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55B8A3F3.6090107@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 29, 2015 at 11:59:15AM +0200, Vlastimil Babka wrote:
> On 07/20/2015 10:00 AM, Mel Gorman wrote:
> > From: Mel Gorman <mgorman@suse.de>
> > 
> > MIGRATE_RESERVE preserves an old property of the buddy allocator that existed
> > prior to fragmentation avoidance -- min_free_kbytes worth of pages tended to
> > remain free until the only alternative was to fail the allocation. At the
> 
>           ^ I think you meant contiguous instead of free?

That is exactly what I meant.

> Is it because
> splitting chooses lowest possible order, and grouping by mobility means you
> might be splitting e.g. order-5 movable page instead of using order-0 unmovable
> page? And that the fallback heuristics specifically select highest available
> order? I think it's not that obvious, so worth mentioning.
> 

Yes, the commit that introduced MIGRATE_RESERVE discusses it so I didn't
repeat it as the git digging is simply

1. Find the commit that introduced MIGRATE_HIGHATOMIC and see it
   replaced MIGRATE_RESERVE
2. Find the commit that introduced MIGRATE_RESERVE

That locates 56fd56b868f1 ("Bias the location of pages freed for
min_free_kbytes in the same MAX_ORDER_NR_PAGES blocks").

> > time it was discovered that high-order atomic allocations relied on this
> > property so MIGRATE_RESERVE was introduced. A later patch will introduce
> > an alternative MIGRATE_HIGHATOMIC so this patch deletes MIGRATE_RESERVE
> > and supporting code so it'll be easier to review. Note that this patch
> > in isolation may look like a false regression if someone was bisecting
> > high-order atomic allocation failures.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
