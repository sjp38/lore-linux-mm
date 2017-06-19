Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5EE6B03C9
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 10:17:07 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f49so2429094wrf.5
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 07:17:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 90si9765087wrp.7.2017.06.19.07.17.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Jun 2017 07:17:06 -0700 (PDT)
Subject: Re: [PATCH] mm: remove a redundant condition in the for loop
References: <20170619135418.8580-1-haolee.swjtu@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e2169d83-8845-7eac-2b81-e5f0b16943a3@suse.cz>
Date: Mon, 19 Jun 2017 16:17:01 +0200
MIME-Version: 1.0
In-Reply-To: <20170619135418.8580-1-haolee.swjtu@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hao Lee <haolee.swjtu@gmail.com>, akpm@linux-foundation.org
Cc: mgorman@techsingularity.net, mhocko@suse.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/19/2017 03:54 PM, Hao Lee wrote:
> The variable current_order decreases from MAX_ORDER-1 to order, so the
> condition current_order <= MAX_ORDER-1 is always true.
> 
> Signed-off-by: Hao Lee <haolee.swjtu@gmail.com>

Sounds right.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2302f25..9120c2b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2215,9 +2215,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>  	bool can_steal;
>  
>  	/* Find the largest possible block of pages in the other list */
> -	for (current_order = MAX_ORDER-1;
> -				current_order >= order && current_order <= MAX_ORDER-1;
> -				--current_order) {
> +	for (current_order = MAX_ORDER-1; current_order >= order;
> +							--current_order) {
>  		area = &(zone->free_area[current_order]);
>  		fallback_mt = find_suitable_fallback(area, current_order,
>  				start_migratetype, false, &can_steal);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
