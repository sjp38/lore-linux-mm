Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D8A796B004F
	for <linux-mm@kvack.org>; Sun, 17 May 2009 22:33:50 -0400 (EDT)
Date: Mon, 18 May 2009 10:34:04 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in
	case of no swap space V3
Message-ID: <20090518023404.GB5869@localhost>
References: <20090514231555.f52c81eb.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090514231555.f52c81eb.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 14, 2009 at 11:15:55PM +0900, MinChan Kim wrote:
 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2f9d555..621708f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1577,7 +1577,7 @@ static void shrink_zone(int priority, struct zone *zone,
>  	 * Even if we did not try to evict anon pages at all, we want to
>  	 * rebalance the anon lru active/inactive ratio.
>  	 */
> -	if (inactive_anon_is_low(zone, sc))
> +	if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
>  		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);

There's another "if (inactive_anon_is_low) shrink_active_list;"
occurrence to be fixed in balance_pgdat()? Otherwise:

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
