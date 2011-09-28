Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 098E29000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:41:10 -0400 (EDT)
Subject: Re: [patch 1/2]vmscan: correct all_unreclaimable for zone without
 lru pages
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110927092830.GB25807@tiehlicka.suse.cz>
References: <1317108184.29510.200.camel@sli10-conroe>
	 <20110927092830.GB25807@tiehlicka.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 28 Sep 2011 08:46:06 +0800
Message-ID: <1317170766.22361.2.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@google.com>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, 2011-09-27 at 17:28 +0800, Michal Hocko wrote:
> On Tue 27-09-11 15:23:04, Shaohua Li wrote:
> [...]
> > Index: linux/mm/vmscan.c
> > ===================================================================
> > --- linux.orig/mm/vmscan.c	2011-09-27 13:46:31.000000000 +0800
> > +++ linux/mm/vmscan.c	2011-09-27 15:09:29.000000000 +0800
> > @@ -2565,7 +2565,9 @@ loop_again:
> >  				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
> >  				total_scanned += sc.nr_scanned;
> >  
> > -				if (nr_slab == 0 && !zone_reclaimable(zone))
> > +				if (nr_slab == 0 && !zone_reclaimable(zone) &&
> > +				    !zone_watermark_ok_safe(zone, order,
> > +				    high_wmark_pages(zone) + balance_gap, 0, 0))
> 
> Hardcoded ZONE_DMA for zone_watermark_ok_safe? Shouldn't this be i for
> classzone_idx?
i or 0 are the same here for lowmem_reserve (both have 0 value),
actually a lot of code are using 0 for zone_watermark_ok

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
