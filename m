Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id CCE366B005A
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 14:55:53 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hn18so7072838igb.9
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:55:53 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id il10si2782691igb.6.2014.09.10.11.55.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 11:55:53 -0700 (PDT)
Received: by mail-ie0-f176.google.com with SMTP id ar1so4728181iec.35
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:55:52 -0700 (PDT)
Date: Wed, 10 Sep 2014 11:55:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memory-hotplug: fix below build warning
In-Reply-To: <1410228703-2496-1-git-send-email-zhenzhang.zhang@huawei.com>
Message-ID: <alpine.DEB.2.02.1409101153340.27173@chino.kir.corp.google.com>
References: <1410228703-2496-1-git-send-email-zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, wangnan0@huawei.com

On Tue, 9 Sep 2014, Zhang Zhen wrote:

> drivers/base/memory.c: In function 'show_valid_zones':
> drivers/base/memory.c:384:22: warning: unused variable 'zone_prev' [-Wunused-variable]
>   struct zone *zone, *zone_prev;
>                       ^
> 
> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>

This is
Reported-by: kbuild test robot <fengguang.wu@intel.com>
on August 29 to this mailing list.

> ---
>  drivers/base/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index efd456c..7c5d871 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -381,7 +381,7 @@ static ssize_t show_valid_zones(struct device *dev,
>  	unsigned long start_pfn, end_pfn;
>  	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
>  	struct page *first_page;
> -	struct zone *zone, *zone_prev;
> +	struct zone *zone;
>  
>  	start_pfn = section_nr_to_pfn(mem->start_section_nr);
>  	end_pfn = start_pfn + nr_pages;

Looks good, but this should already be fixed by
http://ozlabs.org/~akpm/mmotm/broken-out/memory-hotplug-add-sysfs-zones_online_to-attribute-fix-3-fix.patch
right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
