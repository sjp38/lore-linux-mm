Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id AEBE76B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 21:33:26 -0500 (EST)
Received: by pdev10 with SMTP id v10so16113167pde.10
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 18:33:26 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id xi4si506871pbb.109.2015.02.12.18.33.24
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 18:33:25 -0800 (PST)
Date: Fri, 13 Feb 2015 11:35:34 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] Slab infrastructure for array operations
Message-ID: <20150213023534.GA6592@js1304-P5Q-DELUXE>
References: <20150210194804.288708936@linux.com>
 <20150210194811.787556326@linux.com>
 <alpine.DEB.2.10.1502101542030.15535@chino.kir.corp.google.com>
 <alpine.DEB.2.11.1502111243380.3887@gentwo.org>
 <alpine.DEB.2.10.1502111213151.16711@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1502111213151.16711@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Feb 11, 2015 at 12:18:07PM -0800, David Rientjes wrote:
> On Wed, 11 Feb 2015, Christoph Lameter wrote:
> 
> > > This patch is referencing functions that don't exist and can do so since
> > > it's not compiled, but I think this belongs in the next patch.  I also
> > > think that this particular implementation may be slub-specific so I would
> > > have expected just a call to an allocator-defined
> > > __kmem_cache_alloc_array() here with i = __kmem_cache_alloc_array().
> > 
> > The implementation is generic and can be used in the same way for SLAB.
> > SLOB does not have these types of object though.
> > 
> 
> Ok, I didn't know if the slab implementation would follow the same format 
> with the same callbacks or whether this would need to be cleaned up later.  

Hello, Christoph.

I also think that this implementation is slub-specific. For example,
in slab case, it is always better to access local cpu cache first than
page allocator since slab doesn't use list to manage free objects and
there is no cache line overhead like as slub. I think that,
in kmem_cache_alloc_array(), just call to allocator-defined
__kmem_cache_alloc_array() is better approach.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
