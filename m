Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DC9B96B00EA
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 09:56:31 -0400 (EDT)
Date: Wed, 20 Jul 2011 08:56:27 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
In-Reply-To: <20110720134342.GK5349@suse.de>
Message-ID: <alpine.DEB.2.00.1107200854390.32737@router.home>
References: <20110720121612.28888.38970.stgit@localhost6> <alpine.DEB.2.00.1107201611010.3528@tiger> <20110720134342.GK5349@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Pekka Enberg <penberg@kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

On Wed, 20 Jul 2011, Mel Gorman wrote:

> > The changelog isn't that convincing, really. This is
> > kmem_cache_create() so I'm surprised we'd ever get NULL here in
> > practice. Does this fix some problem you're seeing? If this is
> > really an issue, I'd blame the page allocator as GFP_KERNEL should
> > just work.
> >
>
> Besides, is allocating from cache_cache really a
> PAGE_ALLOC_COSTLY_ORDER allocation? On my laptop at least, it's an
> order-2 allocation which is supporting up to 512 CPUs and 512 nodes.

Slab's kmem_cache is configured with an array of NR_CPUS which is the
maximum nr of cpus supported. Some distros support 4096 cpus in order to
accomodate SGI machines. That array then will have the size of 4096 * 8 =
32k

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
