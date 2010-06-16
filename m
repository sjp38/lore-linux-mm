Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 248EE6B01B5
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 13:18:32 -0400 (EDT)
Message-ID: <4C190748.7030400@kernel.org>
Date: Wed, 16 Jun 2010 19:18:00 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [RFC] slub: Simplify boot kmem_cache_cpu allocations
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006151409240.10865@router.home> <4C189119.5050801@kernel.org> <alpine.DEB.2.00.1006161131520.4554@router.home>
In-Reply-To: <alpine.DEB.2.00.1006161131520.4554@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On 06/16/2010 06:33 PM, Christoph Lameter wrote:
> On Wed, 16 Jun 2010, Tejun Heo wrote:
>>> Tejun: Is it somehow possible to reliably use the alloc_percpu() on all
>>> platforms during early boot before the slab allocator is up?
>>
>> Hmmm... first chunk allocation is done using bootmem, so if we give it
>> enough to room (for both chunk itself and alloc map) so that it can
>> serve till slab comes up, it should work fine.  I think what's
>> important here is making up our minds and decide on how to order them.
>> If the order is well defined, things can be made to work one way or
>> the other.  What happened to the get-rid-of-bootmem effort?  Wouldn't
>> that also interact with this?
> 
> Ok how do we make sure that the first chunk has enough room?

It's primarily controlled by PERCPU_DYNAMIC_RESERVE.  I don't think
there will be any systematic way to do it other than sizing it
sufficiently.  Can you calculate the upper bound?  The constant has
been used primarily for optimization so how it's used needs to be
audited if we wanna guarantee free space in the first chunk but I
don't think it would be too difficult.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
