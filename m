Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C96956B0071
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 11:29:58 -0400 (EDT)
Date: Wed, 16 Jun 2010 10:26:32 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 4/4] slub: remove gfp_flags argument from
 create_kmalloc_cache
In-Reply-To: <alpine.DEB.2.00.1006151438220.20327@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006161026020.4554@router.home>
References: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com> <alpine.DEB.2.00.1006082348450.30606@chino.kir.corp.google.com> <alpine.DEB.2.00.1006091124240.21686@router.home> <4C0FC509.9060605@cs.helsinki.fi> <alpine.DEB.2.00.1006151231400.9031@router.home>
 <alpine.DEB.2.00.1006151438220.20327@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2010, David Rientjes wrote:

> > Breaks DMA cache creation since one can no longer set the
> > SLAB_CACHE_DMA on create_kmalloc_cache.
> >
>
> How?  There are no callers to create_kmalloc_cache() that pass anything
> except GFP_NOWAIT.

Ok it breaks it with my changes that use create_kmalloc_dma for dma caches
again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
