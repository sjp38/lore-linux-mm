Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 798EB6B0279
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 01:37:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b184so3304691wme.14
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 22:37:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j14si14048372wrb.98.2017.06.26.22.37.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 22:37:05 -0700 (PDT)
Date: Tue, 27 Jun 2017 07:37:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm: remove unused zone_type variable from
 __remove_zone()
Message-ID: <20170627053702.GC28072@dhcp22.suse.cz>
References: <20170624043421.24465-1-jhubbard@nvidia.com>
 <20170624043421.24465-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170624043421.24465-2-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>

On Fri 23-06-17 21:34:21, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> __remove_zone() is setting up zone_type, but never using
> it for anything. This is not causing a warning, due to
> the (necessary) use of -Wno-unused-but-set-variable.
> However, it's noise, so just delete it.

I plan to remove the function completely FWIW but this is a trivial
impovement.
 
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 567a1dcafa1a..9bd73ecd7248 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -580,11 +580,8 @@ static void __remove_zone(struct zone *zone, unsigned long start_pfn)
>  {
>  	struct pglist_data *pgdat = zone->zone_pgdat;
>  	int nr_pages = PAGES_PER_SECTION;
> -	int zone_type;
>  	unsigned long flags;
>  
> -	zone_type = zone - pgdat->node_zones;
> -
>  	pgdat_resize_lock(zone->zone_pgdat, &flags);
>  	shrink_zone_span(zone, start_pfn, start_pfn + nr_pages);
>  	shrink_pgdat_span(pgdat, start_pfn, start_pfn + nr_pages);
> -- 
> 2.13.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
