Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9086F6B0008
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 11:01:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v17so1091028pff.9
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 08:01:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13si1334354pgn.344.2018.03.20.08.00.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 08:00:57 -0700 (PDT)
Date: Tue, 20 Mar 2018 16:00:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/6] mm/vmscan: Update stale comments
Message-ID: <20180320150054.GX23100@dhcp22.suse.cz>
References: <20180315164553.17856-1-aryabinin@virtuozzo.com>
 <20180315164553.17856-2-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180315164553.17856-2-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Thu 15-03-18 19:45:49, Andrey Ryabinin wrote:
> Update some comments that become stale since transiton from per-zone
> to per-node reclaim.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4390a8d5be41..6d74b12099bd 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -926,7 +926,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
>  
>  		/*
> -		 * The number of dirty pages determines if a zone is marked
> +		 * The number of dirty pages determines if a node is marked
>  		 * reclaim_congested which affects wait_iff_congested. kswapd
>  		 * will stall and start writing pages if the tail of the LRU
>  		 * is all dirty unqueued pages.
> @@ -1764,7 +1764,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	 * as there is no guarantee the dirtying process is throttled in the
>  	 * same way balance_dirty_pages() manages.
>  	 *
> -	 * Once a zone is flagged ZONE_WRITEBACK, kswapd will count the number
> +	 * Once a node is flagged PGDAT_WRITEBACK, kswapd will count the number
>  	 * of pages under pages flagged for immediate reclaim and stall if any
>  	 * are encountered in the nr_immediate check below.
>  	 */
> @@ -1791,7 +1791,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	 */
>  	if (sane_reclaim(sc)) {
>  		/*
> -		 * Tag a zone as congested if all the dirty pages scanned were
> +		 * Tag a node as congested if all the dirty pages scanned were
>  		 * backed by a congested BDI and wait_iff_congested will stall.
>  		 */
>  		if (stat.nr_dirty && stat.nr_dirty == stat.nr_congested)
> @@ -1812,7 +1812,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	}
>  
>  	/*
> -	 * Stall direct reclaim for IO completions if underlying BDIs or zone
> +	 * Stall direct reclaim for IO completions if underlying BDIs and node
>  	 * is congested. Allow kswapd to continue until it starts encountering
>  	 * unqueued dirty pages or cycling through the LRU too quickly.
>  	 */
> @@ -3808,7 +3808,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  
>  	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
>  		/*
> -		 * Free memory by calling shrink zone with increasing
> +		 * Free memory by calling shrink node with increasing
>  		 * priorities until we have enough memory freed.
>  		 */
>  		do {
> -- 
> 2.16.1

-- 
Michal Hocko
SUSE Labs
