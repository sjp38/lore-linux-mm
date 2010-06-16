Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4EE2E6B01B2
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 04:54:16 -0400 (EDT)
Message-ID: <4C189119.5050801@kernel.org>
Date: Wed, 16 Jun 2010 10:53:45 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [RFC] slub: Simplify boot kmem_cache_cpu allocations
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006151409240.10865@router.home>
In-Reply-To: <alpine.DEB.2.00.1006151409240.10865@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Christoph.

On 06/15/2010 09:11 PM, Christoph Lameter wrote:
> Maybe this one can also be applied after the other patch?
> 
> Tejun: Is it somehow possible to reliably use the alloc_percpu() on all
> platforms during early boot before the slab allocator is up?

Hmmm... first chunk allocation is done using bootmem, so if we give it
enough to room (for both chunk itself and alloc map) so that it can
serve till slab comes up, it should work fine.  I think what's
important here is making up our minds and decide on how to order them.
If the order is well defined, things can be made to work one way or
the other.  What happened to the get-rid-of-bootmem effort?  Wouldn't
that also interact with this?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
