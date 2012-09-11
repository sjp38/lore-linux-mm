Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id B25526B00B2
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 04:59:56 -0400 (EDT)
Date: Tue, 11 Sep 2012 09:59:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: cma: Discard clean pages during contiguous
 allocation instead of migration
Message-ID: <20120911085948.GF11266@suse.de>
References: <1347324112-14134-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1347324112-14134-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kmpark@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

On Tue, Sep 11, 2012 at 09:41:52AM +0900, Minchan Kim wrote:
> This patch drops clean cache pages instead of migration during
> alloc_contig_range() to minimise allocation latency by reducing the amount
> of migration is necessary. It's useful for CMA because latency of migration
> is more important than evicting the background processes working set.
> In addition, as pages are reclaimed then fewer free pages for migration
> targets are required so it avoids memory reclaiming to get free pages,
> which is a contributory factor to increased latency.
> 
> * from v1
>   * drop migrate_mode_t
>   * add reclaim_clean_pages_from_list instad of MIGRATE_DISCARD support - Mel
> 
> I measured elapsed time of __alloc_contig_migrate_range which migrates
> 10M in 40M movable zone in QEMU machine.
> 
> Before - 146ms, After - 7ms
> 
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Rik van Riel <riel@redhat.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

My signed-off is already on this but in earlier versions I was still
asking for changes. This time the patch looks good to me so even though
it is a bit redundant.

Reviewed-by: Mel Gorman <mgorman@suse.de>

Thanks Minchan.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
