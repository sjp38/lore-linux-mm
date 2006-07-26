Date: Wed, 26 Jul 2006 11:59:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/2] slab: always consider arch mandated alignment
In-Reply-To: <44C7B842.5060606@colorfullife.com>
Message-ID: <Pine.LNX.4.64.0607261153220.6896@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0607220748160.13737@schroedinger.engr.sgi.com>
 <20060722162607.GA10550@osiris.ibm.com> <Pine.LNX.4.64.0607221241130.14513@schroedinger.engr.sgi.com>
 <20060723073500.GA10556@osiris.ibm.com> <Pine.LNX.4.64.0607230558560.15651@schroedinger.engr.sgi.com>
 <20060723162427.GA10553@osiris.ibm.com> <20060726085113.GD9592@osiris.boeblingen.de.ibm.com>
 <Pine.LNX.4.58.0607261303270.17613@sbz-30.cs.Helsinki.FI>
 <20060726101340.GE9592@osiris.boeblingen.de.ibm.com>
 <Pine.LNX.4.58.0607261325070.17986@sbz-30.cs.Helsinki.FI>
 <20060726105204.GF9592@osiris.boeblingen.de.ibm.com>
 <Pine.LNX.4.58.0607261411420.17986@sbz-30.cs.Helsinki.FI>
 <44C7AF31.9000507@colorfullife.com> <Pine.LNX.4.64.0607261118001.6608@schroedinger.engr.sgi.com>
 <44C7B842.5060606@colorfullife.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jul 2006, Manfred Spraul wrote:

> > Thus the patch is correct, it's a bug in the slab allocator. If
> > HWCACHE_ALIGN
> > > is set, then the allocator ignores align or ARCH_SLAB_MINALIGN.
> >  
> > 
> > But then Heiko does not want to set ARCH_SLAB_MINALIGN at all. This is not
> > the issue we are discussing. In the DEBUG case he wants
> > ARCH_KMALLOC_MINALIGN to be enforced even if ARCH_SLAB_MINALIGN is not set.
> >  
> The kmalloc caches are allocated with HWCACHE_ALIGN+ARCH_KMALLOC_MINALIGN. The
> logic in kmem_cache_create didn't handle that case correctly.
> On most architectures, ARCH_KMALLOC_MINALIGN is 0. Thus SLAB_DEBUG redzones
> everything.
> On s390, ARCH_KMALLOC_MINALIGN is 8. This disables redzoning.
> 
> Ok?

So Redzoning etc will now be diabled regardless even if  
ARCH_SLAB_MINALIGN is not set but another alignment is given to 
kmem_cache_alloc?

So we sacrifice the ability to worsen the performance of slabs by 
misaligning them for debugging purposes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
