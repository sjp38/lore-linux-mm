Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 68A026B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:08:54 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so10190307pbb.19
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 18:08:54 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id xf3si8483746pab.343.2014.04.15.18.08.52
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 18:08:53 -0700 (PDT)
Date: Wed, 16 Apr 2014 10:09:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] mm/page_alloc: DEBUG_VM checks for free_list
 placement of CMA and RESERVE pages
Message-ID: <20140416010917.GA17653@js1304-P5Q-DELUXE>
References: <533D8015.1000106@suse.cz>
 <1396539618-31362-1-git-send-email-vbabka@suse.cz>
 <1396539618-31362-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1396539618-31362-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Yong-Taek Lee <ytk.lee@samsung.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michal Nazarewicz <mina86@mina86.com>

On Thu, Apr 03, 2014 at 05:40:18PM +0200, Vlastimil Babka wrote:
> For the MIGRATE_RESERVE pages, it is important they do not get misplaced
> on free_list of other migratetype, otherwise the whole MIGRATE_RESERVE
> pageblock might be changed to other migratetype in try_to_steal_freepages().
> For MIGRATE_CMA, the pages also must not go to a different free_list, otherwise
> they could get allocated as unmovable and result in CMA failure.
> 
> This is ensured by setting the freepage_migratetype appropriately when placing
> pages on pcp lists, and using the information when releasing them back to
> free_list. It is also assumed that CMA and RESERVE pageblocks are created only
> in the init phase. This patch adds DEBUG_VM checks to catch any regressions
> introduced for this invariant.

Hello, Vlastimil.

Idea looks good to me.

> 
> Cc: Yong-Taek Lee <ytk.lee@samsung.com>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
