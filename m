Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Thu, 3 May 2018 09:51:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Remove useless parameter of finalise_ac
Message-ID: <20180503075111.GB4535@dhcp22.suse.cz>
References: <1525318929-91048-1-git-send-email-yehs1@lenovo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1525318929-91048-1-git-send-email-yehs1@lenovo.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Huaisheng Ye <yehs1@lenovo.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, pasha.tatashin@oracle.com, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, colyli@suse.de, chengnt@lenovo.com
List-ID: <linux-mm.kvack.org>

On Thu 03-05-18 11:42:09, Huaisheng Ye wrote:
> finalise_ac has parameter order which is not used at all.
> Remove it.
> 
> Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 905db9d..291e194 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4326,8 +4326,7 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
>  }
>  
>  /* Determine whether to spread dirty pages and what the first usable zone */
> -static inline void finalise_ac(gfp_t gfp_mask,
> -		unsigned int order, struct alloc_context *ac)
> +static inline void finalise_ac(gfp_t gfp_mask, struct alloc_context *ac)
>  {
>  	/* Dirty zone balancing only done in the fast path */
>  	ac->spread_dirty_pages = (gfp_mask & __GFP_WRITE);
> @@ -4358,7 +4357,7 @@ struct page *
>  	if (!prepare_alloc_pages(gfp_mask, order, preferred_nid, nodemask, &ac, &alloc_mask, &alloc_flags))
>  		return NULL;
>  
> -	finalise_ac(gfp_mask, order, &ac);
> +	finalise_ac(gfp_mask, &ac);
>  
>  	/* First allocation attempt */
>  	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
