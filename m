Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 471A36B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 02:52:46 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id bs8so7143116wib.13
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 23:52:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wt5si3710234wjb.166.2014.06.24.23.52.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 23:52:41 -0700 (PDT)
Date: Wed, 25 Jun 2014 08:52:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm 1/3] page-cgroup: trivial cleanup
Message-ID: <20140625065238.GA10223@dhcp22.suse.cz>
References: <9f5abf8dcb07fe5462f12f81867f199c22e883d3.1403626729.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9f5abf8dcb07fe5462f12f81867f199c22e883d3.1403626729.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 24-06-14 20:33:04, Vladimir Davydov wrote:
> Add forward declarations for struct pglist_data, mem_cgroup.
> 
> Remove __init, __meminit from function prototypes and inline functions.
> 
> Remove redundant inclusion of bit_spinlock.h.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/page_cgroup.h |   22 +++++++++++-----------
>  1 file changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 97b5c39a31c8..23863edb95ff 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -12,8 +12,10 @@ enum {
>  #ifndef __GENERATING_BOUNDS_H
>  #include <generated/bounds.h>
>  
> +struct pglist_data;
> +
>  #ifdef CONFIG_MEMCG
> -#include <linux/bit_spinlock.h>
> +struct mem_cgroup;
>  
>  /*
>   * Page Cgroup can be considered as an extended mem_map.
> @@ -27,16 +29,16 @@ struct page_cgroup {
>  	struct mem_cgroup *mem_cgroup;
>  };
>  
> -void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
> +extern void pgdat_page_cgroup_init(struct pglist_data *pgdat);
>  
>  #ifdef CONFIG_SPARSEMEM
> -static inline void __init page_cgroup_init_flatmem(void)
> +static inline void page_cgroup_init_flatmem(void)
>  {
>  }
> -extern void __init page_cgroup_init(void);
> +extern void page_cgroup_init(void);
>  #else
> -void __init page_cgroup_init_flatmem(void);
> -static inline void __init page_cgroup_init(void)
> +extern void page_cgroup_init_flatmem(void);
> +static inline void page_cgroup_init(void)
>  {
>  }
>  #endif
> @@ -48,11 +50,10 @@ static inline int PageCgroupUsed(struct page_cgroup *pc)
>  {
>  	return test_bit(PCG_USED, &pc->flags);
>  }
> -
> -#else /* CONFIG_MEMCG */
> +#else /* !CONFIG_MEMCG */
>  struct page_cgroup;
>  
> -static inline void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
> +static inline void pgdat_page_cgroup_init(struct pglist_data *pgdat)
>  {
>  }
>  
> @@ -65,10 +66,9 @@ static inline void page_cgroup_init(void)
>  {
>  }
>  
> -static inline void __init page_cgroup_init_flatmem(void)
> +static inline void page_cgroup_init_flatmem(void)
>  {
>  }
> -
>  #endif /* CONFIG_MEMCG */
>  
>  #include <linux/swap.h>
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
