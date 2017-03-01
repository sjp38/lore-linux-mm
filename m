Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 893996B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 10:14:34 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y187so17344228wmy.7
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 07:14:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7si7333010wmz.23.2017.03.01.07.14.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 07:14:33 -0800 (PST)
Date: Wed, 1 Mar 2017 16:14:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/9] mm: remove unnecessary reclaimability check from
 NUMA balancing target
Message-ID: <20170301151432.GD11730@dhcp22.suse.cz>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-5-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228214007.5621-5-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 28-02-17 16:40:02, Johannes Weiner wrote:
> NUMA balancing already checks the watermarks of the target node to
> decide whether it's a suitable balancing target. Whether the node is
> reclaimable or not is irrelevant when we don't intend to reclaim.

I guess the original intention was to skip nodes which are under strong
memory pressure but I agree that this is questionable heuristic.
 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/migrate.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 2c63ac06791b..45a18be27b1a 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1718,9 +1718,6 @@ static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
>  {
>  	int z;
>  
> -	if (!pgdat_reclaimable(pgdat))
> -		return false;
> -
>  	for (z = pgdat->nr_zones - 1; z >= 0; z--) {
>  		struct zone *zone = pgdat->node_zones + z;
>  
> -- 
> 2.11.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
