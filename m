Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C36346B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 04:18:07 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r126so13743926wmr.2
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 01:18:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m15si10506151wrb.74.2017.01.13.01.18.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 01:18:06 -0800 (PST)
Date: Fri, 13 Jan 2017 10:18:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: consider eligible zones in
 get_scan_count
Message-ID: <20170113091804.GE25212@dhcp22.suse.cz>
References: <20170110125552.4170-1-mhocko@kernel.org>
 <20170110125552.4170-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170110125552.4170-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue 10-01-17 13:55:51, Michal Hocko wrote:
[...]
> @@ -2280,7 +2306,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  			unsigned long size;
>  			unsigned long scan;
>  
> -			size = lruvec_lru_size(lruvec, lru);
> +			size = lruvec_lru_size_eligibe_zones(lruvec, lru, sc->reclaim_idx);
>  			scan = size >> sc->priority;
>  
>  			if (!scan && pass && force_scan)

I have just come across inactive_reclaimable_pages and it seems it is
unnecessary after this, right Minchan?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
