Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 528086B02B3
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 03:04:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id t77so16151219pfe.10
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 00:04:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c4si23829268pgu.231.2017.11.28.00.04.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 00:04:36 -0800 (PST)
Date: Tue, 28 Nov 2017 09:04:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmscan: change return type of is_page_cache_freeable
 from int to bool
Message-ID: <20171128080434.z32gfedrzq37rsqe@dhcp22.suse.cz>
References: <1511837307-56494-1-git-send-email-jiang.biao2@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511837307-56494-1-git-send-email-jiang.biao2@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Biao <jiang.biao2@zte.com.cn>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn

On Tue 28-11-17 10:48:27, Jiang Biao wrote:
> Using bool for the return type of is_page_cache_freeable() should be
> more appropriate.

Does this help to generate a better code or why do we want to change
this at all?

> Signed-off-by: Jiang Biao <jiang.biao2@zte.com.cn>
> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eb2f031..5fe63ed 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -530,7 +530,7 @@ void drop_slab(void)
>  		drop_slab_node(nid);
>  }
>  
> -static inline int is_page_cache_freeable(struct page *page)
> +static inline bool is_page_cache_freeable(struct page *page)
>  {
>  	/*
>  	 * A freeable page cache page is referenced only by the caller
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
