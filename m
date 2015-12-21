Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED136B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 05:14:57 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p187so61383254wmp.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 02:14:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id da7si48192608wjb.185.2015.12.21.02.14.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Dec 2015 02:14:55 -0800 (PST)
Subject: Re: [PATCH] mm: move lru_to_page to mm_inline.h
References: <db243314728321f435fb82dc2b5d99d98af409e2.1450515627.git.geliangtang@163.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5677D11D.9030203@suse.cz>
Date: Mon, 21 Dec 2015 11:14:53 +0100
MIME-Version: 1.0
In-Reply-To: <db243314728321f435fb82dc2b5d99d98af409e2.1450515627.git.geliangtang@163.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/19/2015 10:08 AM, Geliang Tang wrote:
> Move lru_to_page() from internal.h to mm_inline.h.

The file already contains functionality related to lru.

> Signed-off-by: Geliang Tang <geliangtang@163.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   include/linux/mm_inline.h | 2 ++
>   mm/internal.h             | 2 --
>   mm/readahead.c            | 1 +
>   3 files changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> index cf55945..712e8c3 100644
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -100,4 +100,6 @@ static __always_inline enum lru_list page_lru(struct page *page)
>   	return lru;
>   }
>
> +#define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
> +
>   #endif
> diff --git a/mm/internal.h b/mm/internal.h
> index ca49922..5d8ec89 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -87,8 +87,6 @@ extern int isolate_lru_page(struct page *page);
>   extern void putback_lru_page(struct page *page);
>   extern bool zone_reclaimable(struct zone *zone);
>
> -#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> -
>   /*
>    * in mm/rmap.c:
>    */
> diff --git a/mm/readahead.c b/mm/readahead.c
> index 0aff760..20e58e8 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -17,6 +17,7 @@
>   #include <linux/pagemap.h>
>   #include <linux/syscalls.h>
>   #include <linux/file.h>
> +#include <linux/mm_inline.h>
>
>   #include "internal.h"
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
