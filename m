Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CD7326B008A
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 06:19:49 -0500 (EST)
Date: Thu, 9 Dec 2010 11:19:30 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/5] Prevent kswapd dumping excessive amounts of memory
	in response to high-order allocations V3
Message-ID: <20101209111930.GQ5422@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Bah, this should have been PATCH 0/6 of course :(

On Thu, Dec 09, 2010 at 11:18:14AM +0000, Mel Gorman wrote:
> There was a minor bug in V2 that led to this release.  I'm hopeful it'll
> stop kswapd going mad on Simon's machine and might also alleviate some of
> the "too much free memory" problem.
> 
> Changelog since V2
>   o Add clarifying comments
>   o Properly check that the zone is balanced for order-0
>   o Treat zone->all_unreclaimable properly
> 
> Changelog since V1
>   o Take classzone into account
>   o Ensure that kswapd always balances at order-09
>   o Reset classzone and order after reading
>   o Require a percentage of a node be balanced for high-order allocations,
>     not just any zone as ZONE_DMA could be balanced when the node in general
>     is a mess
> 
> <SNIP>

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
