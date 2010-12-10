Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EA8EB6B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 05:43:14 -0500 (EST)
Date: Fri, 10 Dec 2010 10:42:54 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/6] mm: kswapd: Reset kswapd_max_order and
	classzone_idx after reading
Message-ID: <20101210104254.GL20133@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie> <1291893500-12342-5-git-send-email-mel@csn.ul.ie> <20101209155925.GD1740@barrios-desktop> <AANLkTimKVZjfVtZ_Rz0p0xKbE76Uoa1rDrYmN9EC4wLU@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <AANLkTimKVZjfVtZ_Rz0p0xKbE76Uoa1rDrYmN9EC4wLU@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 10, 2010 at 01:03:01AM +0900, Minchan Kim wrote:
> On Fri, Dec 10, 2010 at 12:59 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> > On Thu, Dec 09, 2010 at 11:18:18AM +0000, Mel Gorman wrote:
> >> When kswapd wakes up, it reads its order and classzone from pgdat and
> >> calls balance_pgdat. While its awake, it potentially reclaimes at a high
> >> order and a low classzone index. This might have been a once-off that
> >> was not required by subsequent callers. However, because the pgdat
> >> values were not reset, they remain artifically high while
> >> balance_pgdat() is running and potentially kswapd enters a second
> >> unnecessary reclaim cycle. Reset the pgdat order and classzone index
> >> after reading.
> >>
> >> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> Nitpick.
> Shouldn't this patch be merged with 1/6?
> 

I don't think so as it's a standalone fix. For example, if this was
merged on its own, the "order" should still be reset after reading.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
