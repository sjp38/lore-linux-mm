Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f41.google.com (mail-lf0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA8B6B0253
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 05:43:02 -0400 (EDT)
Received: by mail-lf0-f41.google.com with SMTP id g184so86785351lfb.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 02:43:02 -0700 (PDT)
Received: from mail-lf0-f54.google.com (mail-lf0-f54.google.com. [209.85.215.54])
        by mx.google.com with ESMTPS id h141si15441810lfb.77.2016.04.04.02.43.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 02:43:01 -0700 (PDT)
Received: by mail-lf0-f54.google.com with SMTP id p188so133984205lfd.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 02:43:00 -0700 (PDT)
Date: Mon, 4 Apr 2016 11:42:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm:vmscan: clean up classzone_idx
Message-ID: <20160404094259.GC13463@dhcp22.suse.cz>
References: <1459727185-5753-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459727185-5753-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Mon 04-04-16 08:46:25, Minchan Kim wrote:
> [1] removed classzone_idx so we don't need code related to it.
> This patch cleans it up.
> 
> [1] mm, oom: rework oom detection

As per http://lkml.kernel.org/r/20160404094213.GB13463@dhcp22.suse.cz
the removal of classzone_idx was unintentional and wrong.

> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/vmscan.c | 8 --------
>  1 file changed, 8 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d84efa03c8a8..6e67de2a61ed 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2551,16 +2551,8 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  					gfp_zone(sc->gfp_mask), sc->nodemask) {
> -		enum zone_type classzone_idx;
> -
>  		if (!populated_zone(zone))
>  			continue;
> -
> -		classzone_idx = requested_highidx;
> -		while (!populated_zone(zone->zone_pgdat->node_zones +
> -							classzone_idx))
> -			classzone_idx--;
> -
>  		/*
>  		 * Take care memory controller reclaiming has small influence
>  		 * to global LRU.
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
