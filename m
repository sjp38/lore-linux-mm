Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id D2A656B0034
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 14:04:53 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id xb12so2056639pbc.12
        for <linux-mm@kvack.org>; Sun, 16 Jun 2013 11:04:53 -0700 (PDT)
Date: Sun, 16 Jun 2013 11:04:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Add unlikely for current_order test
In-Reply-To: <51BC4A83.50302@gmail.com>
Message-ID: <alpine.DEB.2.02.1306161103020.22688@chino.kir.corp.google.com>
References: <51BC4A83.50302@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sat, 15 Jun 2013, Zhang Yanfei wrote:

> From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> 
> Since we have an unlikely for the "current_order >= pageblock_order / 2"
> test above, adding an unlikely for this "current_order >= pageblock_order"
> test seems more appropriate.
> 

I don't understand the justification at all, current_order being unlikely 
greater than or equal to pageblock_order / 2 doesn't imply at all that 
it's unlikely that current_order is greater than or equal to 
pageblock_order.

> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  mm/page_alloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c3edb62..1b6d7de 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1071,7 +1071,7 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>  			rmv_page_order(page);
>  
>  			/* Take ownership for orders >= pageblock_order */
> -			if (current_order >= pageblock_order &&
> +			if (unlikely(current_order >= pageblock_order) &&
>  			    !is_migrate_cma(migratetype))
>  				change_pageblock_range(page, current_order,
>  							start_migratetype);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
