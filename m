Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id EAE916B0253
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 10:35:42 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id na2so28779042lbb.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 07:35:42 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id d135si4447508wmd.75.2016.06.20.07.35.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 07:35:41 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r201so14599967wme.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 07:35:41 -0700 (PDT)
Date: Mon, 20 Jun 2016 16:35:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Delete meaningless check of current_order in
 __rmqueue_fallback
Message-ID: <20160620143539.GG9892@dhcp22.suse.cz>
References: <1465754611-21398-1-git-send-email-masanori.yoshida.lkml@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465754611-21398-1-git-send-email-masanori.yoshida.lkml@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YOSHIDA Masanori <masanori.yoshida.lkml@gmail.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, rientjes@google.com, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, hannes@cmpxchg.org, linux-mm@kvack.org, YOSHIDA Masanori <masanori.yoshida@gmail.com>

On Mon 13-06-16 03:03:31, YOSHIDA Masanori wrote:
> From: YOSHIDA Masanori <masanori.yoshida@gmail.com>
> 
> Signed-off-by: YOSHIDA Masanori <masanori.yoshida@gmail.com>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6903b69..db02967 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2105,7 +2105,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>  
>  	/* Find the largest possible block of pages in the other list */
>  	for (current_order = MAX_ORDER-1;
> -				current_order >= order && current_order <= MAX_ORDER-1;
> +				current_order >= order;
>  				--current_order) {
>  		area = &(zone->free_area[current_order]);
>  		fallback_mt = find_suitable_fallback(area, current_order,

This is incorrect. Guess what happens if the given order is 0. Hint,
current_order is unsigned int.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
