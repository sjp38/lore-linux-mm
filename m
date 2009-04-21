Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DD9F16B003D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 06:08:17 -0400 (EDT)
Date: Tue, 21 Apr 2009 11:08:20 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 11/25] Calculate the cold parameter for allocation only
	once
Message-ID: <20090421100818.GO12713@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-12-git-send-email-mel@csn.ul.ie> <20090421180551.F142.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090421180551.F142.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 06:07:24PM +0900, KOSAKI Motohiro wrote:
> > GFP mask is checked for __GFP_COLD has been specified when deciding which
> > end of the PCP lists to use. However, it is happening multiple times per
> > allocation, at least once per zone traversed. Calculate it once.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/page_alloc.c |   35 ++++++++++++++++++-----------------
> >  1 files changed, 18 insertions(+), 17 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 1506cd5..51e1ded 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1066,11 +1066,10 @@ void split_page(struct page *page, unsigned int order)
> >   */
> >  static struct page *buffered_rmqueue(struct zone *preferred_zone,
> >  			struct zone *zone, int order, gfp_t gfp_flags,
> > -			int migratetype)
> > +			int migratetype, int cold)
> >  {
> >  	unsigned long flags;
> >  	struct page *page;
> > -	int cold = !!(gfp_flags & __GFP_COLD);
> >  	int cpu;
> 
> Honestly, I don't like this ;-)
> 
> It seems benefit is too small. It don't win against code ugliness, I think.
> 

Ok, I'll drop it for now and then generate figures for it at a later
time. The intention is to have this first set relatively
uncontroversial.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
