Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF846B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 13:58:16 -0400 (EDT)
Date: Wed, 1 Jun 2011 18:58:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110601175809.GB7306@suse.de>
References: <20110530131300.GQ5044@csn.ul.ie>
 <20110530143109.GH19505@random.random>
 <20110530153748.GS5044@csn.ul.ie>
 <20110530165546.GC5118@suse.de>
 <20110530175334.GI19505@random.random>
 <20110531121620.GA3490@barrios-laptop>
 <20110531122437.GJ19505@random.random>
 <20110531133340.GB3490@barrios-laptop>
 <20110531141402.GK19505@random.random>
 <20110601005747.GC7019@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110601005747.GC7019@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Wed, Jun 01, 2011 at 01:57:47AM +0100, Mel Gorman wrote:
> On Tue, May 31, 2011 at 04:14:02PM +0200, Andrea Arcangeli wrote:
> > On Tue, May 31, 2011 at 10:33:40PM +0900, Minchan Kim wrote:
> > > I checked them before sending patch but I got failed to find strange things. :(
> > 
> > My review also doesn't show other bugs in migrate_pages callers like
> > that one.
> > 
> > > Now I am checking the page's SwapBacked flag can be changed
> > > between before and after of migrate_pages so accounting of NR_ISOLATED_XX can
> > > make mistake. I am approaching the failure, too. Hmm.
> > 
> > When I checked that, I noticed the ClearPageSwapBacked in swapcache if
> > radix insertion fails, but that happens before adding the page in the
> > LRU so it shouldn't have a chance to be isolated.
> > 
> 
> After hammering three machines for several hours, I managed to trigger
> this once on x86 !CONFIG_SMP CONFIG_PREEMPT HIGHMEM4G (so no PAE)
> and caught the following trace.
> 

Umm, HIGHMEM4G implies a two-level pagetable layout so where are
things like _PAGE_BIT_SPLITTING being set when THP is enabled?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
