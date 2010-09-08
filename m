Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5876B004A
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 02:15:40 -0400 (EDT)
Date: Wed, 8 Sep 2010 08:15:28 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 04/10] vmscan: Synchronous lumpy reclaim should not call
 congestion_wait()
Message-ID: <20100908061528.GD20955@cmpxchg.org>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
 <1283770053-18833-5-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1283770053-18833-5-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 06, 2010 at 11:47:27AM +0100, Mel Gorman wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> congestion_wait() mean "waiting queue congestion is cleared".  However,
> synchronous lumpy reclaim does not need this congestion_wait() as
> shrink_page_list(PAGEOUT_IO_SYNC) uses wait_on_page_writeback()
> and it provides the necessary waiting.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

> ---
>  mm/vmscan.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eabe987..5979850 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1341,8 +1341,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  
>  	/* Check if we should syncronously wait for writeback */
>  	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
> -		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> -
>  		/*
>  		 * The attempt at page out may have made some
>  		 * of the pages active, mark them inactive again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
