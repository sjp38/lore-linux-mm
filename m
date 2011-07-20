Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A35076B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 10:20:24 -0400 (EDT)
Date: Wed, 20 Jul 2011 15:20:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
Message-ID: <20110720142018.GL5349@suse.de>
References: <20110720121612.28888.38970.stgit@localhost6>
 <alpine.DEB.2.00.1107201611010.3528@tiger>
 <4E26D7EA.3000902@parallels.com>
 <alpine.DEB.2.00.1107201638520.4921@tiger>
 <alpine.DEB.2.00.1107200852590.32737@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1107200852590.32737@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Konstantin Khlebnikov <khlebnikov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>

On Wed, Jul 20, 2011 at 08:54:10AM -0500, Christoph Lameter wrote:
> On Wed, 20 Jul 2011, Pekka Enberg wrote:
> 
> > On Wed, 20 Jul 2011, Konstantin Khlebnikov wrote:
> > > > The changelog isn't that convincing, really. This is kmem_cache_create()
> > > > so I'm surprised we'd ever get NULL here in practice. Does this fix some
> > > > problem you're seeing? If this is really an issue, I'd blame the page
> > > > allocator as GFP_KERNEL should just work.
> > >
> > > nf_conntrack creates separate slab-cache for each net-namespace,
> > > this patch of course not eliminates the chance of failure, but makes it more
> > > acceptable.
> >
> > I'm still surprised you are seeing failures. mm/slab.c hasn't changed
> > significantly in a long time. Why hasn't anyone reported this before? I'd
> > still be inclined to shift the blame to the page allocator... Mel, Christoph?
> 
> There was a lot of recent fiddling with the reclaim logic. Maybe some of
> those changes caused the problem?
> 

It's more likely that creating new slabs while under memory pressure
significant enough to fail an order-4 allocation is a situation that is
rarely tested. 

What kernel version did this failure occur on? What was the system doing
at the time of failure? Can the page allocation failure message be
posted?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
