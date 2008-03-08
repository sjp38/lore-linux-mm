Date: Sat, 8 Mar 2008 12:57:03 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/13] General DMA zone rework
Message-ID: <20080308115703.GD27074@one.firstfloor.org>
References: <200803071007.493903088@firstfloor.org> <Pine.LNX.4.64.0803071841020.12220@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803071841020.12220@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 07, 2008 at 06:42:21PM -0800, Christoph Lameter wrote:
> On Fri, 7 Mar 2008, Andi Kleen wrote:
> 
> > The longer term goal is to convert all GFP_DMA allocations
> > to always specify the correct mask and then eventually remove
> > GFP_DMA.
> > 
> > Especially I hope kmalloc/kmem_cache_alloc GFP_DMA can be
> > removed soon. I have some patches to eliminate those users.
> > Then slab wouldn't need to maintain DMA caches anymore.
> 
> That would be greatly appreciated. Thanks for doing this.

I'm afraid it would not help you directly because you would still need 
to maintain that code for s390 (seems to be a heavy GFP_DMA user)
and probably some other architectures (unless you can get these
maintainers to get rid of GFP_DMA too) With my plan it can be just ifdefed
and the ifdef not enabled on x86.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
