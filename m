Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D29C26B0266
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 03:03:57 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id v72so7566208pgb.10
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 00:03:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j6-v6si18979952pgb.62.2018.11.13.00.03.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 00:03:56 -0800 (PST)
Date: Tue, 13 Nov 2018 09:03:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 5/5] mm, memory_hotplug: be more verbose for memory
 offline failures
Message-ID: <20181113080354.GJ15120@dhcp22.suse.cz>
References: <20181107101830.17405-1-mhocko@kernel.org>
 <20181107101830.17405-6-mhocko@kernel.org>
 <b23ebcb3-e4f1-be78-bd5f-84c685979ab7@arm.com>
 <20181108081231.GN27423@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181108081231.GN27423@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Andrew, could you pick up this one as well please? Let me know if you
prefer me to send the whole pile with all the fixes again.

> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index bf214beccda3..820397e18e59 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1411,9 +1411,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
>  		if (ret) {
>  			list_for_each_entry(page, &source, lru) {
> -				pr_warn("migrating pfn %lx failed ",
> +				pr_warn("migrating pfn %lx failed ret:%d ",
>  				       page_to_pfn(page), ret);
> -				dump_page(page, NULL);
> +				dump_page(page, "migration failure");
>  			}
>  			putback_movable_pages(&source);
>  		}
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 23267767bf98..ec2c7916dc2d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7845,7 +7845,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	return false;
>  unmovable:
>  	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
> -	dump_page(pfn_to_page(pfn+iter), "has_unmovable_pages");
> +	dump_page(pfn_to_page(pfn+iter), "unmovable page");
>  	return true;
>  }
>  
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs
