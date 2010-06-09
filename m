Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BD5C56B01AD
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 15:47:37 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o59JlYEU016239
	for <linux-mm@kvack.org>; Wed, 9 Jun 2010 12:47:34 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by kpbe16.cbf.corp.google.com with ESMTP id o59JlV21015995
	for <linux-mm@kvack.org>; Wed, 9 Jun 2010 12:47:33 -0700
Received: by pwi9 with SMTP id 9so958686pwi.30
        for <linux-mm@kvack.org>; Wed, 09 Jun 2010 12:47:31 -0700 (PDT)
Date: Wed, 9 Jun 2010 12:47:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 3/4] slub: use is_kmalloc_cache in dma_kmalloc_cache
In-Reply-To: <alpine.DEB.2.00.1006091120460.21686@router.home>
Message-ID: <alpine.DEB.2.00.1006091246160.26827@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com> <alpine.DEB.2.00.1006082348310.30606@chino.kir.corp.google.com> <alpine.DEB.2.00.1006091120460.21686@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jun 2010, Christoph Lameter wrote:

> > diff --git a/mm/slub.c b/mm/slub.c
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2649,13 +2649,12 @@ static noinline struct kmem_cache *dma_kmalloc_cache(int index, gfp_t flags)
> >  	text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
> >  			 (unsigned int)realsize);
> >
> > -	s = NULL;
> >  	for (i = 0; i < KMALLOC_CACHES; i++)
> >  		if (!kmalloc_caches[i].size)
> >  			break;
> >
> > -	BUG_ON(i >= KMALLOC_CACHES);
> >  	s = kmalloc_caches + i;
> > +	BUG_ON(!is_kmalloc_cache(s));
> 
> The point here is to check if the index I is still within the bonds of
> kmalloc_cache. Use of is_kmalloc_cache() will confuse the reader.
> 

Why does that confuse the reader?  It ensures that s is actually still a 
kmalloc_cache, meaning that i is within the bounds of the kmalloc_caches 
array.  Seems pretty straightforward to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
