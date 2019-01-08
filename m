Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DEA6C8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 04:10:29 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so1317859edb.22
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 01:10:29 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id q5-v6si4275073ejs.232.2019.01.08.01.10.27
        for <linux-mm@kvack.org>;
        Tue, 08 Jan 2019 01:10:27 -0800 (PST)
Date: Tue, 8 Jan 2019 10:10:26 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v4] mm: remove extra drain pages on pcp list
Message-ID: <20190108091019.ax2mzjcvrpknn6ve@d104.suse.de>
References: <20181221170228.10686-1-richard.weiyang@gmail.com>
 <20190105233141.2329-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190105233141.2329-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, david@redhat.com

On Sun, Jan 06, 2019 at 07:31:41AM +0800, Wei Yang wrote:
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> 
> ---
> v4:
>   * adjust last two paragraph changelog from Michal's comment
> v3:
>   * it is not proper to rely on caller to drain pages, so keep to drain
>     pages during iteration and remove the one in callers.
> v2: adjust changelog with MIGRATE_ISOLATE effects for the isolated range
> ---
>  mm/memory_hotplug.c | 1 -
>  mm/page_alloc.c     | 1 -
>  2 files changed, 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 6910e0eea074..d2fa6cbbb2db 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1599,7 +1599,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  
>  	cond_resched();
>  	lru_add_drain_all();
> -	drain_all_pages(zone);
>  
>  	pfn = scan_movable_pages(start_pfn, end_pfn);
>  	if (pfn) { /* We have movable pages */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f1edd36a1e2b..d9ee4bb3a1a7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8041,7 +8041,6 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  	 */
>  
>  	lru_add_drain_all();
> -	drain_all_pages(cc.zone);
>  
>  	order = 0;
>  	outer_start = start;
> -- 
> 2.15.1
> 

-- 
Oscar Salvador
SUSE L3
