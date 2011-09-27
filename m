Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F0C2D9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 05:28:36 -0400 (EDT)
Date: Tue, 27 Sep 2011 11:28:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2]vmscan: correct all_unreclaimable for zone without
 lru pages
Message-ID: <20110927092830.GB25807@tiehlicka.suse.cz>
References: <1317108184.29510.200.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1317108184.29510.200.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@google.com>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue 27-09-11 15:23:04, Shaohua Li wrote:
[...]
> Index: linux/mm/vmscan.c
> ===================================================================
> --- linux.orig/mm/vmscan.c	2011-09-27 13:46:31.000000000 +0800
> +++ linux/mm/vmscan.c	2011-09-27 15:09:29.000000000 +0800
> @@ -2565,7 +2565,9 @@ loop_again:
>  				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
>  				total_scanned += sc.nr_scanned;
>  
> -				if (nr_slab == 0 && !zone_reclaimable(zone))
> +				if (nr_slab == 0 && !zone_reclaimable(zone) &&
> +				    !zone_watermark_ok_safe(zone, order,
> +				    high_wmark_pages(zone) + balance_gap, 0, 0))

Hardcoded ZONE_DMA for zone_watermark_ok_safe? Shouldn't this be i for
classzone_idx?

>  					zone->all_unreclaimable = 1;
>  			}
>  

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
