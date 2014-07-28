Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id BFB3A6B0037
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 11:27:56 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id b13so7507802wgh.30
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 08:27:55 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id dw12si34700002wjb.138.2014.07.28.08.27.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 08:27:54 -0700 (PDT)
Message-ID: <53D66BF4.1070200@infradead.org>
Date: Mon, 28 Jul 2014 08:27:48 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix filemap.c pagecache_get_page() kernel-doc warnings
References: <53D564ED.1030906@infradead.org> <20140728093630.GM10819@suse.de>
In-Reply-To: <20140728093630.GM10819@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On 07/28/14 02:36, Mel Gorman wrote:
> On Sun, Jul 27, 2014 at 01:45:33PM -0700, Randy Dunlap wrote:
>> From: Randy Dunlap <rdunlap@infradead.org>
>>
>> Fix kernel-doc warnings in mm/filemap.c: pagecache_get_page():
>>
>> Warning(..//mm/filemap.c:1054): No description found for parameter 'cache_gfp_mask'
>> Warning(..//mm/filemap.c:1054): No description found for parameter 'radix_gfp_mask'
>> Warning(..//mm/filemap.c:1054): Excess function parameter 'gfp_mask' description in 'pagecache_get_page'
>>
>> Fixes: 2457aec63745 "mm: non-atomically mark page accessed during
>> 	page cache allocation where possible"
>>
>> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
>> Cc: Mel Gorman <mgorman@suse.de>
> 
> Use this diff instead?

Sure.  Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

Andrew?

> 
> ---8<---
> diff --git a/mm/filemap.c b/mm/filemap.c
> index dafb06f..a1021fa 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1031,18 +1031,21 @@ EXPORT_SYMBOL(find_lock_entry);
>   * @mapping: the address_space to search
>   * @offset: the page index
>   * @fgp_flags: PCG flags
> - * @gfp_mask: gfp mask to use if a page is to be allocated
> + * @cache_gfp_mask: gfp mask to use for the page cache data page allocation
> + * @radix_gfp_mask: gfp mask to use for radix tree node allocation
>   *
>   * Looks up the page cache slot at @mapping & @offset.
>   *
> - * PCG flags modify how the page is returned
> + * PCG flags modify how the page is returned.
>   *
>   * FGP_ACCESSED: the page will be marked accessed
>   * FGP_LOCK: Page is return locked
>   * FGP_CREAT: If page is not present then a new page is allocated using
> - *		@gfp_mask and added to the page cache and the VM's LRU
> - *		list. The page is returned locked and with an increased
> - *		refcount. Otherwise, %NULL is returned.
> + *		@cache_gfp_mask and added to the page cache and the VM's LRU
> + *		list. If radix tree nodes are allocated during page cache
> + *		insertion then @radix_gfp_mask is used. The page is returned
> + * 		locked and with an increased refcount. Otherwise, %NULL is
> + * 		returned.
>   *
>   * If FGP_LOCK or FGP_CREAT are specified then the function may sleep even
>   * if the GFP flags specified for FGP_CREAT are atomic.
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
