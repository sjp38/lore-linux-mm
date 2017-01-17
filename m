Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5D76B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 05:25:36 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id an2so15972308wjc.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:25:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si24529737wrb.2.2017.01.17.02.25.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 02:25:34 -0800 (PST)
Date: Tue, 17 Jan 2017 11:25:32 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: respect pre-allocated storage mapping for memmap
Message-ID: <20170117102532.GH19699@dhcp22.suse.cz>
References: <1484573885-54353-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484573885-54353-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: dan.j.williams@intel.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Mon 16-01-17 21:38:05, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> At present, we skip the reservation storage by the driver for
> the zone_dvice. but the free pages set aside for the memmap is
> ignored. And since the free pages is only used as the memmap,
> so we can also skip the corresponding pages.

I have really hard time to understand what this patch does and why it
matters.  Could you please rephrase the changelog to state, the problem,
how it affects users and what is the fix please?
 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d604d25..51d8d03 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5047,7 +5047,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  	 * memory
>  	 */
>  	if (altmap && start_pfn == altmap->base_pfn)
> -		start_pfn += altmap->reserve;
> +		start_pfn += vmem_altmap_offset(altmap);
>  
>  	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>  		/*
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
