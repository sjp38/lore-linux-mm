Date: Fri, 7 Mar 2008 18:42:21 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] [0/13] General DMA zone rework
In-Reply-To: <200803071007.493903088@firstfloor.org>
Message-ID: <Pine.LNX.4.64.0803071841020.12220@schroedinger.engr.sgi.com>
References: <200803071007.493903088@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Andi Kleen wrote:

> The longer term goal is to convert all GFP_DMA allocations
> to always specify the correct mask and then eventually remove
> GFP_DMA.
> 
> Especially I hope kmalloc/kmem_cache_alloc GFP_DMA can be
> removed soon. I have some patches to eliminate those users.
> Then slab wouldn't need to maintain DMA caches anymore.

That would be greatly appreciated. Thanks for doing this.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
