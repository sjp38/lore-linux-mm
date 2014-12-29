Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id ECCAC6B006E
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 07:11:00 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so21867651wid.9
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 04:11:00 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id o16si58451019wie.63.2014.12.29.04.11.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 04:11:00 -0800 (PST)
Received: by mail-wi0-f177.google.com with SMTP id l15so21831181wiw.16
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 04:11:00 -0800 (PST)
Date: Mon, 29 Dec 2014 13:10:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH TRIVIAL] swap: remove unused
 mem_cgroup_uncharge_swapcache declaration
Message-ID: <20141229121057.GB32618@dhcp22.suse.cz>
References: <1419854337-15161-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1419854337-15161-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 29-12-14 14:58:57, Vladimir Davydov wrote:
> The body of this function was removed by commit 0a31bc97c80c ("mm:
> memcontrol: rewrite uncharge API").
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/swap.h |   15 ---------------
>  mm/shmem.c           |    2 +-
>  2 files changed, 1 insertion(+), 16 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 34e8b60ab973..7067eca501e2 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -437,16 +437,6 @@ extern int reuse_swap_page(struct page *);
>  extern int try_to_free_swap(struct page *);
>  struct backing_dev_info;
>  
> -#ifdef CONFIG_MEMCG
> -extern void
> -mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout);
> -#else
> -static inline void
> -mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
> -{
> -}
> -#endif
> -
>  #else /* CONFIG_SWAP */
>  
>  #define swap_address_space(entry)		(NULL)
> @@ -547,11 +537,6 @@ static inline swp_entry_t get_swap_page(void)
>  	return entry;
>  }
>  
> -static inline void
> -mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
> -{
> -}
> -
>  #endif /* CONFIG_SWAP */
>  #endif /* __KERNEL__*/
>  #endif /* _LINUX_SWAP_H */
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 185836ba53ef..0c92e925c4bf 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1131,7 +1131,7 @@ repeat:
>  			 * truncated or holepunched since swap was confirmed.
>  			 * shmem_undo_range() will have done some of the
>  			 * unaccounting, now delete_from_swap_cache() will do
> -			 * the rest (including mem_cgroup_uncharge_swapcache).
> +			 * the rest.
>  			 * Reset swap.val? No, leave it so "failed" goes back to
>  			 * "repeat": reading a hole and writing should succeed.
>  			 */
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
