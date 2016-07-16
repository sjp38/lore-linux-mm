Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4896B0253
	for <linux-mm@kvack.org>; Sat, 16 Jul 2016 06:14:30 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id q2so228228191pap.1
        for <linux-mm@kvack.org>; Sat, 16 Jul 2016 03:14:30 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id h3si1500540pfg.65.2016.07.16.03.14.28
        for <linux-mm@kvack.org>;
        Sat, 16 Jul 2016 03:14:29 -0700 (PDT)
Date: Sat, 16 Jul 2016 19:14:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/5] mm: show node_pages_scanned per node, not zone
Message-ID: <20160716101431.GA10305@bbox>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
 <1468588165-12461-5-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468588165-12461-5-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 15, 2016 at 02:09:24PM +0100, Mel Gorman wrote:
> From: Minchan Kim <minchan@kernel.org>
> 
> The node_pages_scanned represents the number of scanned pages
> of node for reclaim so it's pointless to show it as kilobytes.
> 
> As well, node_pages_scanned is per-node value, not per-zone.
> 
> This patch changes node_pages_scanned per-zone-killobytes
> with per-node-count.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/page_alloc.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f80a0e57dcc8..7edd311a63f1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4345,6 +4345,7 @@ void show_free_areas(unsigned int filter)
>  #endif
>  			" writeback_tmp:%lukB"
>  			" unstable:%lukB"
> +			" pages_scanned:%lu"
>  			" all_unreclaimable? %s"
>  			"\n",
>  			pgdat->node_id,
> @@ -4367,6 +4368,7 @@ void show_free_areas(unsigned int filter)
>  			K(node_page_state(pgdat, NR_SHMEM)),
>  			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
>  			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
> +			node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED),

Oops, It should be pgdat, not zone->zone_pgdat.
Andrew, please fold it.
