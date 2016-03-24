Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9606B025E
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 00:09:19 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id nk17so105510376igb.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 21:09:19 -0700 (PDT)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id 9si8182371igz.17.2016.03.23.21.09.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 23 Mar 2016 21:09:18 -0700 (PDT)
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhlcindy@imap.linux.ibm.com>;
	Wed, 23 Mar 2016 22:09:17 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 005F4C400BD
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 21:49:11 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2O412QC45678830
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 21:01:02 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2O412QF003474
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 22:01:02 -0600
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 24 Mar 2016 12:00:52 +0800
From: zhlcindy <zhlcindy@imap.linux.ibm.com>
Subject: Re: [PATCH 1/1] mm/page_alloc: Remove useless parameter of
 __free_pages_boot_core
In-Reply-To: <1458791480-20324-1-git-send-email-zhlcindy@gmail.com>
References: <1458791480-20324-1-git-send-email-zhlcindy@gmail.com>
Message-ID: <5ed84fae352de403ca23306666cb25bb@imap.linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhang <zhlcindy@gmail.com>
Cc: mgorman@techsingularity.net, vbabka@suse.cz, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

Sorry, a mail address in TO list is wrong. Correct it.

On 2016-03-24 11:51, Li Zhang wrote:
> From: Li Zhang <zhlcindy@linux.vnet.ibm.com>
> 
> __free_pages_boot_core has parameter pfn which is not used at all.
> So this patch is to make it clean.
> 
> Signed-off-by: Li Zhang <zhlcindy@linux.vnet.ibm.com>
> ---
>  mm/page_alloc.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a762be5..8c0affe 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1056,8 +1056,7 @@ static void __free_pages_ok(struct page *page,
> unsigned int order)
>  	local_irq_restore(flags);
>  }
> 
> -static void __init __free_pages_boot_core(struct page *page,
> -					unsigned long pfn, unsigned int order)
> +static void __init __free_pages_boot_core(struct page *page, unsigned
> int order)
>  {
>  	unsigned int nr_pages = 1 << order;
>  	struct page *p = page;
> @@ -1134,7 +1133,7 @@ void __init __free_pages_bootmem(struct page
> *page, unsigned long pfn,
>  {
>  	if (early_page_uninitialised(pfn))
>  		return;
> -	return __free_pages_boot_core(page, pfn, order);
> +	return __free_pages_boot_core(page, order);
>  }
> 
>  /*
> @@ -1219,12 +1218,12 @@ static void __init deferred_free_range(struct
> page *page,
>  	if (nr_pages == MAX_ORDER_NR_PAGES &&
>  	    (pfn & (MAX_ORDER_NR_PAGES-1)) == 0) {
>  		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> -		__free_pages_boot_core(page, pfn, MAX_ORDER-1);
> +		__free_pages_boot_core(page, MAX_ORDER-1);
>  		return;
>  	}
> 
> -	for (i = 0; i < nr_pages; i++, page++, pfn++)
> -		__free_pages_boot_core(page, pfn, 0);
> +	for (i = 0; i < nr_pages; i++, page++)
> +		__free_pages_boot_core(page, 0);
>  }
> 
>  /* Completion tracking for deferred_init_memmap() threads */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
