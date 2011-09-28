Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 075AD9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:43:57 -0400 (EDT)
Subject: Re: [patch 2/2]vmscan: correctly detect GFP_ATOMIC allocation
 failure
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110927112810.GA3897@tiehlicka.suse.cz>
References: <1317108187.29510.201.camel@sli10-conroe>
	 <20110927112810.GA3897@tiehlicka.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 28 Sep 2011 08:48:53 +0800
Message-ID: <1317170933.22361.5.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@google.com>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, 2011-09-27 at 19:28 +0800, Michal Hocko wrote:
> On Tue 27-09-11 15:23:07, Shaohua Li wrote:
> > has_under_min_watermark_zone is used to detect if there is GFP_ATOMIC allocation
> > failure risk. For a high end_zone, if any zone below or equal to it has min
> > matermark ok, we have no risk. But current logic is any zone has min watermark
> > not ok, then we have risk. This is wrong to me.
> 
> This, however, means that we skip congestion_wait more often as ZONE_DMA
> tend to be mostly balanced, right? This would mean that kswapd could hog
> CPU more.
We actually might have more congestion_wait, as now if any zone can meet
min watermark, we don't have has_under_min_watermark_zone set so do
congestion_wait

> Does this fix any particular problem you are seeing?
No, just thought the logic is wrong.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
