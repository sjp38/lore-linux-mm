Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B63EF6B01AD
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 13:39:58 -0400 (EDT)
Message-ID: <4C1BAF51.8020702@kernel.org>
Date: Fri, 18 Jun 2010 19:39:29 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] percpu: make @dyn_size always mean min dyn_size in
 first chunk init functions
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006151409240.10865@router.home> <4C189119.5050801@kernel.org> <alpine.DEB.2.00.1006161131520.4554@router.home> <4C190748.7030400@kernel.org> <alpine.DEB.2.00.1006161231420.6361@router.home> <4C19E19D.2020802@kernel.org> <alpine.DEB.2.00.1006170842410.22997@router.home> <4C1BA59C.6000309@kernel.org> <alpine.DEB.2.00.1006181229310.13915@router.home>
In-Reply-To: <alpine.DEB.2.00.1006181229310.13915@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On 06/18/2010 07:31 PM, Christoph Lameter wrote:
> We need SLUB_PAGE_SHIFT * sizeof(kmem_cache_cpu). So it would be
> 
> BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE < SLUB_PAGE_SHIFT * sizeof(struct
> kmem_cache_cpu))?

Yeah, something like that but I would add some buffer there for
alignment and whatnot.

> What is the role of SLOTS?

It's allocation map.  Each consecutive allocs consume one if alignment
doesn't require padding but two if it does.  ie. It limits how many
items one can allocate.

> Each kmem_cache_cpu structure is a separate percpu allocation.

If it's a single item.  Nothing to worry about.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
