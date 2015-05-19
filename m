Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id BB03F6B0098
	for <linux-mm@kvack.org>; Tue, 19 May 2015 03:44:07 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so12578202pac.2
        for <linux-mm@kvack.org>; Tue, 19 May 2015 00:44:07 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id wu8si19735973pbc.217.2015.05.19.00.44.05
        for <linux-mm@kvack.org>;
        Tue, 19 May 2015 00:44:07 -0700 (PDT)
Date: Tue, 19 May 2015 16:44:30 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] mm/page_alloc: don't break highest order freepage if
 steal
Message-ID: <20150519074429.GC12092@js1304-P5Q-DELUXE>
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
 <5551B11C.4080000@suse.cz>
 <5551B1CB.7070301@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5551B1CB.7070301@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Tue, May 12, 2015 at 09:54:51AM +0200, Vlastimil Babka wrote:
> On 05/12/2015 09:51 AM, Vlastimil Babka wrote:
> >>   {
> >>   	struct page *page;
> >>+	bool steal_fallback;
> >>
> >>-retry_reserve:
> >>+retry:
> >>   	page = __rmqueue_smallest(zone, order, migratetype);
> >>
> >>   	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
> >>   		if (migratetype == MIGRATE_MOVABLE)
> >>   			page = __rmqueue_cma_fallback(zone, order);
> >>
> >>-		if (!page)
> >>-			page = __rmqueue_fallback(zone, order, migratetype);
> >>+		if (page)
> >>+			goto out;
> >>+
> >>+		steal_fallback = __rmqueue_fallback(zone, order, migratetype);
> 
> Oh and the variable can be probably replaced by calling
> __rmqueue_fallback directly in the if() below.

Will do.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
