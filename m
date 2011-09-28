Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D6EAC9000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 05:27:54 -0400 (EDT)
Date: Wed, 28 Sep 2011 11:27:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2]vmscan: correctly detect GFP_ATOMIC allocation failure
Message-ID: <20110928092751.GA15062@tiehlicka.suse.cz>
References: <1317108187.29510.201.camel@sli10-conroe>
 <20110927112810.GA3897@tiehlicka.suse.cz>
 <1317170933.22361.5.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1317170933.22361.5.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@google.com>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed 28-09-11 08:48:53, Shaohua Li wrote:
> On Tue, 2011-09-27 at 19:28 +0800, Michal Hocko wrote:
> > On Tue 27-09-11 15:23:07, Shaohua Li wrote:
> > > has_under_min_watermark_zone is used to detect if there is GFP_ATOMIC allocation
> > > failure risk. For a high end_zone, if any zone below or equal to it has min
> > > matermark ok, we have no risk. But current logic is any zone has min watermark
> > > not ok, then we have risk. This is wrong to me.
> > 
> > This, however, means that we skip congestion_wait more often as ZONE_DMA
> > tend to be mostly balanced, right? This would mean that kswapd could hog
> > CPU more.
> We actually might have more congestion_wait, as now if any zone can meet
> min watermark, we don't have has_under_min_watermark_zone set so do
> congestion_wait

Ahh, sorry, got confused.

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
