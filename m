Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB17C6B0261
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 07:10:54 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 34so7946018plm.23
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 04:10:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k187si4962011pge.377.2018.01.10.04.10.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Jan 2018 04:10:53 -0800 (PST)
Date: Wed, 10 Jan 2018 13:10:49 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm/page_owner: Clean up init_pages_in_zone()
Message-ID: <20180110121049.GS1732@dhcp22.suse.cz>
References: <20180110084355.GA22822@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110084355.GA22822@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, vbabka@suse.cz, akpm@linux-foundation.org

On Wed 10-01-18 09:43:55, Oscar Salvador wrote:
> This patch removes two redundant assignments in init_pages_in_zone function.
> 
> Signed-off-by: Oscar Salvador <osalvador@techadventures.net>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_owner.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 69f83fc763bb..b361781e5ab6 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -528,14 +528,11 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
>  
>  static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  {
> -	struct page *page;
> -	struct page_ext *page_ext;
>  	unsigned long pfn = zone->zone_start_pfn, block_end_pfn;
>  	unsigned long end_pfn = pfn + zone->spanned_pages;
>  	unsigned long count = 0;
>  
>  	/* Scan block by block. First and last block may be incomplete */
> -	pfn = zone->zone_start_pfn;
>  
>  	/*
>  	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
> @@ -551,9 +548,9 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>  		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
>  		block_end_pfn = min(block_end_pfn, end_pfn);
>  
> -		page = pfn_to_page(pfn);
> -
>  		for (; pfn < block_end_pfn; pfn++) {
> +			struct page *page;
> +			struct page_ext *page_ext;
>  			if (!pfn_valid_within(pfn))
>  				continue;
>  
> -- 
> 2.13.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
