Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 3FE456B005D
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:45:59 -0400 (EDT)
Date: Fri, 28 Sep 2012 14:45:57 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK1 [09/13] slab: rename nodelists to node
In-Reply-To: <506562F9.6010707@parallels.com>
Message-ID: <0000013a0d575212-87f28683-92a4-438a-a0f4-5d3b96c4b26d-000000@email.amazonses.com>
References: <20120926200005.911809821@linux.com> <0000013a0430a882-06cc02cd-4623-41f6-b4c9-702e0c37acb2-000000@email.amazonses.com> <506562F9.6010707@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Fri, 28 Sep 2012, Glauber Costa wrote:

> >
> > -extern struct kmem_cache *cs_cachep[PAGE_SHIFT + MAX_ORDER];
> > -extern struct kmem_cache *cs_dmacachep[PAGE_SHIFT + MAX_ORDER];
> > -
> >
> >  void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
> >  void *__kmalloc(size_t size, gfp_t flags);
> >
> > @@ -132,10 +129,10 @@ static __always_inline void *kmalloc(siz
> >
> >  #ifdef CONFIG_ZONE_DMA
> >  		if (flags & GFP_DMA)
> > -			cachep = cs_dmacachep[i];
> > +			cachep = kmalloc_dma_caches[i];
> >  		else
> You had just changed this to those new names in patch 7. Why don't you
> change it directly to kmalloc_{,dma}_caches ?

Right. This is also not really related to what this patch ought to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
