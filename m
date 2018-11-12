Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC306B0003
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 03:09:29 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so1371378edb.22
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 00:09:28 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y2-v6si282812ejq.177.2018.11.12.00.09.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 00:09:27 -0800 (PST)
Date: Mon, 12 Nov 2018 09:09:26 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: skip zone who has no managed_pages in
 calculate_totalreserve_pages()
Message-ID: <20181112080926.GA14987@dhcp22.suse.cz>
References: <20181112071404.13620-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181112071404.13620-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Mon 12-11-18 15:14:04, Wei Yang wrote:
> Zone with no managed_pages doesn't contribute totalreserv_pages. And the
> more nodes we have, the more empty zones there are.
> 
> This patch skip the zones to save some cycles.

What is the motivation for the patch? Does it really cause any
measurable difference in performance?

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/page_alloc.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a919ba5cb3c8..567de15e1106 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7246,6 +7246,9 @@ static void calculate_totalreserve_pages(void)
>  			struct zone *zone = pgdat->node_zones + i;
>  			long max = 0;
>  
> +			if (!managed_zone(zone))
> +				continue;
> +
>  			/* Find valid and maximum lowmem_reserve in the zone */
>  			for (j = i; j < MAX_NR_ZONES; j++) {
>  				if (zone->lowmem_reserve[j] > max)
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
