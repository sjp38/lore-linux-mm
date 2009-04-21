Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B1F3F6B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 05:01:05 -0400 (EDT)
Date: Tue, 21 Apr 2009 10:01:02 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 25/25] Use a pre-calculated value instead of
	num_online_nodes() in fast paths
Message-ID: <20090421090102.GI12713@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-26-git-send-email-mel@csn.ul.ie> <1240301300.771.58.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1240301300.771.58.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 11:08:20AM +0300, Pekka Enberg wrote:
> On Mon, 2009-04-20 at 23:20 +0100, Mel Gorman wrote:
> > diff --git a/mm/slab.c b/mm/slab.c
> > index 1c680e8..41d1343 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -3579,7 +3579,7 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp)
> >  	 * variable to skip the call, which is mostly likely to be present in
> >  	 * the cache.
> >  	 */
> > -	if (numa_platform && cache_free_alien(cachep, objp))
> > +	if (numa_platform > 1 && cache_free_alien(cachep, objp))
> >  		return;
> 
> This doesn't look right. I assume you meant "nr_online_nodes > 1" here?
> If so, please go ahead and remove "numa_platform" completely.
> 

It would need to be nr_possible_nodes which would be a separate patch to add
the definition and then drop numa_platform. This change is wrong as part of
this patch. I'll drop it. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
