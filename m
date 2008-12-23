Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E9DEB6B004F
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 09:44:30 -0500 (EST)
Subject: Re: [PATCH] failslab for SLUB
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20081223144307.GA3215@cmpxchg.org>
References: <20081223103616.GA7217@localhost.localdomain>
	 <Pine.LNX.4.64.0812231459580.18017@melkki.cs.Helsinki.FI>
	 <20081223144307.GA3215@cmpxchg.org>
Date: Tue, 23 Dec 2008 16:44:26 +0200
Message-Id: <1230043466.11073.0.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Akinobu Mita <akinobu.mita@gmail.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Hannes,

On Tue, 2008-12-23 at 15:43 +0100, Johannes Weiner wrote:
> >  static inline void *____cache_alloc(struct kmem_cache *cachep,
> gfp_t flags)
> >  {
> >  	void *objp;
> > @@ -3381,7 +3316,7 @@ __cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
> >  	unsigned long save_flags;
> >  	void *ptr;
> >  
> > -	if (should_failslab(cachep, flags))
> > +	if (slab_should_failslab(cachep, flags))
> 
> should_failslab()?

No, look at what slab_should_failslab() does. We need to exclude
cache_cache in SLAB but not in SLUB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
