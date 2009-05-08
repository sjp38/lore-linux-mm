Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9106B0083
	for <linux-mm@kvack.org>; Fri,  8 May 2009 14:24:42 -0400 (EDT)
Date: Fri, 8 May 2009 13:24:29 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 2/7] slob: use PG_slab for identifying SLOB pages
Message-ID: <20090508182428.GW31071@waste.org>
References: <20090507012116.996644836@intel.com> <20090507014914.067348097@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090507014914.067348097@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Thu, May 07, 2009 at 09:21:19AM +0800, Wu Fengguang wrote:
> For the sake of consistency.
> 
> Cc: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Matt Mackall <mpm@selenic.com>

Pekka, please take this one directly.

> ---
>  include/linux/page-flags.h |    2 --
>  mm/slob.c                  |    6 +++---
>  2 files changed, 3 insertions(+), 5 deletions(-)
> 
> --- linux.orig/include/linux/page-flags.h
> +++ linux/include/linux/page-flags.h
> @@ -120,7 +120,6 @@ enum pageflags {
>  	PG_savepinned = PG_dirty,
>  
>  	/* SLOB */
> -	PG_slob_page = PG_active,
>  	PG_slob_free = PG_private,
>  
>  	/* SLUB */
> @@ -203,7 +202,6 @@ PAGEFLAG(SavePinned, savepinned);			/* X
>  PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
>  PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
>  
> -__PAGEFLAG(SlobPage, slob_page)
>  __PAGEFLAG(SlobFree, slob_free)
>  
>  __PAGEFLAG(SlubFrozen, slub_frozen)
> --- linux.orig/mm/slob.c
> +++ linux/mm/slob.c
> @@ -132,17 +132,17 @@ static LIST_HEAD(free_slob_large);
>   */
>  static inline int is_slob_page(struct slob_page *sp)
>  {
> -	return PageSlobPage((struct page *)sp);
> +	return PageSlab((struct page *)sp);
>  }
>  
>  static inline void set_slob_page(struct slob_page *sp)
>  {
> -	__SetPageSlobPage((struct page *)sp);
> +	__SetPageSlab((struct page *)sp);
>  }
>  
>  static inline void clear_slob_page(struct slob_page *sp)
>  {
> -	__ClearPageSlobPage((struct page *)sp);
> +	__ClearPageSlab((struct page *)sp);
>  }
>  
>  static inline struct slob_page *slob_page(const void *addr)
> 
> -- 

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
