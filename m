Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7CD6B0289
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:44:04 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y15so11290344wrc.6
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:44:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q82si1245760wmg.50.2017.12.19.04.44.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 04:44:02 -0800 (PST)
Date: Tue, 19 Dec 2017 13:44:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 5/5] mm: Rename zone_statistics() to numa_statistics()
Message-ID: <20171219124401.GQ2787@dhcp22.suse.cz>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
 <1513665566-4465-6-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513665566-4465-6-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue 19-12-17 14:39:26, Kemi Wang wrote:
> Since the functionality of zone_statistics() updates numa counters, but
> numa statistics has been separated from zone statistics framework. Thus,
> the function name makes people confused. So, change the name to
> numa_statistics() as well as its call sites accordingly.
> 
> Signed-off-by: Kemi Wang <kemi.wang@intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 81e8d8f..f7583de 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2790,7 +2790,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>   *
>   * Must be called with interrupts disabled.
>   */
> -static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
> +static inline void numa_statistics(struct zone *preferred_zone, struct zone *z)
>  {
>  #ifdef CONFIG_NUMA
>  	int preferred_nid = preferred_zone->node;
> @@ -2854,7 +2854,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
>  	page = __rmqueue_pcplist(zone,  migratetype, pcp, list);
>  	if (page) {
>  		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
> -		zone_statistics(preferred_zone, zone);
> +		numa_statistics(preferred_zone, zone);
>  	}
>  	local_irq_restore(flags);
>  	return page;
> @@ -2902,7 +2902,7 @@ struct page *rmqueue(struct zone *preferred_zone,
>  				  get_pcppage_migratetype(page));
>  
>  	__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
> -	zone_statistics(preferred_zone, zone);
> +	numa_statistics(preferred_zone, zone);
>  	local_irq_restore(flags);
>  
>  out:
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
