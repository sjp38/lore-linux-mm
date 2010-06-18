Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4BF6D6B01AC
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 13:34:47 -0400 (EDT)
Date: Fri, 18 Jun 2010 12:31:31 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/2] percpu: make @dyn_size always mean min dyn_size in
 first chunk init functions
In-Reply-To: <4C1BA59C.6000309@kernel.org>
Message-ID: <alpine.DEB.2.00.1006181229310.13915@router.home>
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006151409240.10865@router.home> <4C189119.5050801@kernel.org> <alpine.DEB.2.00.1006161131520.4554@router.home> <4C190748.7030400@kernel.org> <alpine.DEB.2.00.1006161231420.6361@router.home>
 <4C19E19D.2020802@kernel.org> <alpine.DEB.2.00.1006170842410.22997@router.home> <4C1BA59C.6000309@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Jun 2010, Tejun Heo wrote:

> It would be a good idea to add BUILD_BUG_ON() in slab to verify
> allocation limits against PERCPU_DYNAMIC_EARLY_SIZE/SLOTS.  Please
> note that two alloc slots might be necessary for each allocation and
> there can be gaps in allocation due to alignment, so giving it some
> headroom would be better.
>
> Please let me know if it's okay for slab.  I'll push it through
> percpu#for-next then.

We need SLUB_PAGE_SHIFT * sizeof(kmem_cache_cpu). So it would be

BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE < SLUB_PAGE_SHIFT * sizeof(struct
kmem_cache_cpu))?

What is the role of SLOTS?

Each kmem_cache_cpu structure is a separate percpu allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
