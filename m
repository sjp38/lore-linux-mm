Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 77D1D6B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 12:57:55 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g7so29146196wrd.16
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 09:57:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g50si25300752wrd.40.2017.04.04.09.57.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 09:57:54 -0700 (PDT)
Date: Tue, 4 Apr 2017 18:57:51 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, memory_hotplug: fix devm_memremap_pages() after
 memory_hotplug rework
Message-ID: <20170404165751.GR15132@dhcp22.suse.cz>
References: <20170404165144.29791-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170404165144.29791-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>

On Tue 04-04-17 12:51:44, Jerome Glisse wrote:
> Just a trivial fix.
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Dan Williams <dan.j.williams@intel.com>

Thanks for catching this! I will fold this into the patch.

> ---
>  kernel/memremap.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index faa9276..bbbe646 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -366,7 +366,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>  	error = arch_add_memory(nid, align_start, align_size);
>  	if (!error)
>  		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
> -				align_start, align_size);
> +					align_start >> PAGE_SHIFT,
> +					align_size >> PAGE_SHIFT);
>  	mem_hotplug_done();
>  	if (error)
>  		goto err_add_memory;
> -- 
> 2.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
