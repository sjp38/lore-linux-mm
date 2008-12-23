Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC0C6B0044
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 10:22:35 -0500 (EST)
Date: Tue, 23 Dec 2008 16:22:23 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] failslab for SLUB
Message-ID: <20081223152223.GA3436@cmpxchg.org>
References: <20081223103616.GA7217@localhost.localdomain> <Pine.LNX.4.64.0812231459580.18017@melkki.cs.Helsinki.FI> <20081223144307.GA3215@cmpxchg.org> <1230043466.11073.0.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1230043466.11073.0.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Akinobu Mita <akinobu.mita@gmail.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 23, 2008 at 04:44:26PM +0200, Pekka Enberg wrote:
> Hi Hannes,
> 
> On Tue, 2008-12-23 at 15:43 +0100, Johannes Weiner wrote:
> > >  static inline void *____cache_alloc(struct kmem_cache *cachep,
> > gfp_t flags)
> > >  {
> > >  	void *objp;
> > > @@ -3381,7 +3316,7 @@ __cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
> > >  	unsigned long save_flags;
> > >  	void *ptr;
> > >  
> > > -	if (should_failslab(cachep, flags))
> > > +	if (slab_should_failslab(cachep, flags))
> > 
> > should_failslab()?
> 
> No, look at what slab_should_failslab() does. We need to exclude
> cache_cache in SLAB but not in SLUB.

Ah, crap.  I missed that small '+' and thought it had been dropped. 

Sorry, Pekka.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
