Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC0D6B01B2
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 05:01:45 -0400 (EDT)
Message-ID: <4C19E476.9010303@cs.helsinki.fi>
Date: Thu, 17 Jun 2010 12:01:42 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [RFC] slub: Simplify boot kmem_cache_cpu allocations
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006151409240.10865@router.home> <4C189119.5050801@kernel.org> <alpine.DEB.2.00.1006161131520.4554@router.home> <4C190748.7030400@kernel.org> <alpine.DEB.2.00.1006161231420.6361@router.home> <4C19E19D.2020802@kernel.org>
In-Reply-To: <4C19E19D.2020802@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/17/10 11:49 AM, Tejun Heo wrote:
> Hello,
>
> On 06/16/2010 07:35 PM, Christoph Lameter wrote:
>>> It's primarily controlled by PERCPU_DYNAMIC_RESERVE.  I don't think
>>> there will be any systematic way to do it other than sizing it
>>> sufficiently.  Can you calculate the upper bound?  The constant has
>>> been used primarily for optimization so how it's used needs to be
>>> audited if we wanna guarantee free space in the first chunk but I
>>> don't think it would be too difficult.
>>
>> The upper bound is SLUB_PAGE_SHIFT * sizeof(struct kmem_cache_cpu).
>>
>> Thats usually 14 * 104 bytes = 1456 bytes. This may increase to more
>> than 8k given the future plans to add queues into kmem_cache_cpu.
>
> Alright, will work on that.  Does slab allocator guarantee to return
> NULL if called before initialized or is it undefined?  If latter, is
> there a way to determine whether slab is initialized yet?

It's undefined and you can use slab_is_available() to check if it's 
available or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
