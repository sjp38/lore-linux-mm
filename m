Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 874A36B0055
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:30:40 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E831582C6EB
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:41:15 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id naSQjDodbNhm for <linux-mm@kvack.org>;
	Tue, 21 Apr 2009 11:41:09 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 854B982C6F5
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:41:04 -0400 (EDT)
Date: Tue, 21 Apr 2009 11:09:59 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 25/25] Use a pre-calculated value instead of num_online_nodes()
 in fast paths
In-Reply-To: <20090421090102.GI12713@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0904211109450.19969@qirst.com>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-26-git-send-email-mel@csn.ul.ie> <1240301300.771.58.camel@penberg-laptop> <20090421090102.GI12713@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Apr 2009, Mel Gorman wrote:

> On Tue, Apr 21, 2009 at 11:08:20AM +0300, Pekka Enberg wrote:
> > On Mon, 2009-04-20 at 23:20 +0100, Mel Gorman wrote:
> > > diff --git a/mm/slab.c b/mm/slab.c
> > > index 1c680e8..41d1343 100644
> > > --- a/mm/slab.c
> > > +++ b/mm/slab.c
> > > @@ -3579,7 +3579,7 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp)
> > >  	 * variable to skip the call, which is mostly likely to be present in
> > >  	 * the cache.
> > >  	 */
> > > -	if (numa_platform && cache_free_alien(cachep, objp))
> > > +	if (numa_platform > 1 && cache_free_alien(cachep, objp))
> > >  		return;
> >
> > This doesn't look right. I assume you meant "nr_online_nodes > 1" here?
> > If so, please go ahead and remove "numa_platform" completely.
> >
>
> It would need to be nr_possible_nodes which would be a separate patch to add
> the definition and then drop numa_platform. This change is wrong as part of
> this patch. I'll drop it. Thanks

nr_online_nodes would be okay as Pekka suggested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
