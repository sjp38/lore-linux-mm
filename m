Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5EDFC6B0082
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 10:52:07 -0400 (EDT)
Date: Wed, 20 Jul 2011 09:52:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
In-Reply-To: <1311170893.2338.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Message-ID: <alpine.DEB.2.00.1107200950270.1472@router.home>
References: <20110720121612.28888.38970.stgit@localhost6>  <alpine.DEB.2.00.1107201611010.3528@tiger> <20110720134342.GK5349@suse.de>  <alpine.DEB.2.00.1107200854390.32737@router.home> <1311170893.2338.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

On Wed, 20 Jul 2011, Eric Dumazet wrote:

> > Slab's kmem_cache is configured with an array of NR_CPUS which is the
> > maximum nr of cpus supported. Some distros support 4096 cpus in order to
> > accomodate SGI machines. That array then will have the size of 4096 * 8 =
> > 32k
>
> We currently support a dynamic schem for the possible nodes :
>
> cache_cache.buffer_size = offsetof(struct kmem_cache, nodelists) +
> 	nr_node_ids * sizeof(struct kmem_list3 *);
>
> We could have a similar trick to make the real size both depends on
> nr_node_ids and nr_cpu_ids.
>
> (struct kmem_cache)->array would become a pointer.

We should be making it a per cpu pointer like slub then. I looked at what
it would take to do so a couple of month ago but it was quite invasive.

The other solution is to use slub instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
