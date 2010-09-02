Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 19AA76B004D
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 04:51:34 -0400 (EDT)
Date: Thu, 2 Sep 2010 09:51:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
	NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100902085118.GA7670@csn.ul.ie>
References: <1283276257-1793-1-git-send-email-mel@csn.ul.ie> <1283276257-1793-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1009011942150.21189@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009011942150.21189@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 01, 2010 at 07:43:41PM -0500, Christoph Lameter wrote:
> On Tue, 31 Aug 2010, Mel Gorman wrote:
> 
> > +#ifdef CONFIG_SMP
> > +/* Called when a more accurate view of NR_FREE_PAGES is needed */
> > +unsigned long zone_nr_free_pages(struct zone *zone)
> > +{
> > +	unsigned long nr_free_pages = zone_page_state(zone, NR_FREE_PAGES);
> 
> You cannot call zone_page_state here because zone_page_state clips the
> counter at zero. The nr_free_pages needs to reflect the unclipped state
> and then the deltas need to be added. Then the clipping at zero can be
> done.
> 

Good point. This justifies the use of a generic helper that is co-located
with vmstat.h. I've taken your zone_page_state_snapshot() patch, am using
the helper to take a more accurate reading of NR_FREE_PAGES and preparing
for a test.  Thanks Christoph.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
