Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E68BC6B01AF
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 12:36:59 -0400 (EDT)
Date: Wed, 16 Jun 2010 11:33:38 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC] slub: Simplify boot kmem_cache_cpu allocations
In-Reply-To: <4C189119.5050801@kernel.org>
Message-ID: <alpine.DEB.2.00.1006161131520.4554@router.home>
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006151409240.10865@router.home> <4C189119.5050801@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jun 2010, Tejun Heo wrote:

> > Tejun: Is it somehow possible to reliably use the alloc_percpu() on all
> > platforms during early boot before the slab allocator is up?
>
> Hmmm... first chunk allocation is done using bootmem, so if we give it
> enough to room (for both chunk itself and alloc map) so that it can
> serve till slab comes up, it should work fine.  I think what's
> important here is making up our minds and decide on how to order them.
> If the order is well defined, things can be made to work one way or
> the other.  What happened to the get-rid-of-bootmem effort?  Wouldn't
> that also interact with this?

Ok how do we make sure that the first chunk has enough room?

Slab bootstrap occurs after the page allocator has taken over from
bootmem and after the per cpu areas have been initialized.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
