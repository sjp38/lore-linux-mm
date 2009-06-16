Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 58F256B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 05:05:06 -0400 (EDT)
Date: Tue, 16 Jun 2009 10:05:10 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] Count the number of times zone_reclaim() scans and
	fails
Message-ID: <20090616090509.GA14241@csn.ul.ie>
References: <1244717273-15176-1-git-send-email-mel@csn.ul.ie> <1244717273-15176-4-git-send-email-mel@csn.ul.ie> <20090615141912.878168ca.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090615141912.878168ca.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, cl@linux-foundation.org, fengguang.wu@intel.com, linuxram@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 02:19:12PM -0700, Andrew Morton wrote:
> On Thu, 11 Jun 2009 11:47:53 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > +		PGSCAN_ZONERECLAIM_FAILED,
> > @@ -2492,6 +2492,9 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> > +	"zreclaim_failed",
> 
> So we have "zonereclaim", "zone_reclaim" and "zreclaim", which isn't
> terribly developer-friendly.
> 
> 
> This?
> 

Acked-by: Mel Gorman <mel@csn.ul.ie>

> --- a/include/linux/vmstat.h~vmscan-count-the-number-of-times-zone_reclaim-scans-and-fails-fix
> +++ a/include/linux/vmstat.h
> @@ -37,7 +37,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
>  		FOR_ALL_ZONES(PGSCAN_KSWAPD),
>  		FOR_ALL_ZONES(PGSCAN_DIRECT),
>  #ifdef CONFIG_NUMA
> -		PGSCAN_ZONERECLAIM_FAILED,
> +		PGSCAN_ZONE_RECLAIM_FAILED,
>  #endif
>  		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
>  		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> diff -puN mm/vmscan.c~vmscan-count-the-number-of-times-zone_reclaim-scans-and-fails-fix mm/vmscan.c
> --- a/mm/vmscan.c~vmscan-count-the-number-of-times-zone_reclaim-scans-and-fails-fix
> +++ a/mm/vmscan.c
> @@ -2520,7 +2520,7 @@ int zone_reclaim(struct zone *zone, gfp_
>  	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
>  
>  	if (!ret)
> -		count_vm_event(PGSCAN_ZONERECLAIM_FAILED);
> +		count_vm_event(PGSCAN_ZONE_RECLAIM_FAILED);
>  
>  	return ret;
>  }
> diff -puN mm/vmstat.c~vmscan-count-the-number-of-times-zone_reclaim-scans-and-fails-fix mm/vmstat.c
> --- a/mm/vmstat.c~vmscan-count-the-number-of-times-zone_reclaim-scans-and-fails-fix
> +++ a/mm/vmstat.c
> @@ -674,7 +674,7 @@ static const char * const vmstat_text[] 
>  	TEXTS_FOR_ZONES("pgscan_direct")
>  
>  #ifdef CONFIG_NUMA
> -	"zreclaim_failed",
> +	"zone_reclaim_failed",
>  #endif
>  	"pginodesteal",
>  	"slabs_scanned",
> _
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
