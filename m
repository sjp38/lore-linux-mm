Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 5DBCC6B0034
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 18:34:37 -0400 (EDT)
Date: Fri, 14 Jun 2013 15:34:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Remove unused functions is_{normal_idx, normal,
 dma32, dma}
Message-Id: <20130614153435.d52163692609400691491161@linux-foundation.org>
In-Reply-To: <51BB0EF1.7040303@gmail.com>
References: <51BB0EF1.7040303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, 14 Jun 2013 20:39:13 +0800 Zhang Yanfei <zhangyanfei.yes@gmail.com> wrote:

> From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> 
> These functions are nowhere used, so remove them.
> 
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -843,11 +843,6 @@ static inline int is_highmem_idx(enum zone_type idx)
>  #endif
>  }
>  
> -static inline int is_normal_idx(enum zone_type idx)
> -{
> -	return (idx == ZONE_NORMAL);
> -}
> -
>  /**
>   * is_highmem - helper function to quickly check if a struct zone is a 
>   *              highmem zone or not.  This is an attempt to keep references
> @@ -866,29 +861,6 @@ static inline int is_highmem(struct zone *zone)
>  #endif
>  }
>  
> -static inline int is_normal(struct zone *zone)
> -{
> -	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
> -}
> -
> -static inline int is_dma32(struct zone *zone)
> -{
> -#ifdef CONFIG_ZONE_DMA32
> -	return zone == zone->zone_pgdat->node_zones + ZONE_DMA32;
> -#else
> -	return 0;
> -#endif
> -}
> -
> -static inline int is_dma(struct zone *zone)
> -{
> -#ifdef CONFIG_ZONE_DMA
> -	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
> -#else
> -	return 0;
> -#endif
> -}
> -
>  /* These two functions are used to setup the per zone pages min values */
>  struct ctl_table;
>  int min_free_kbytes_sysctl_handler(struct ctl_table *, int,

huh.

My first inclination is to leave them alone - they cause no harm apart
from a tiny increase in compilation time and they might be used in the
future.

But their names are all quite poor - should be zone_is_normal(), etc.

So yes, let's zap them and hope that if they get resurrected, it will
be with better naming.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
