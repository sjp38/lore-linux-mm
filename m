Date: Tue, 15 Nov 2005 08:43:26 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] Make the slab allocator observe NUMA policies
In-Reply-To: <200511150434.15094.ak@suse.de>
Message-ID: <Pine.LNX.4.62.0511150841150.9258@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511101401390.16481@schroedinger.engr.sgi.com>
 <200511141944.33478.ak@suse.de> <Pine.LNX.4.62.0511141055560.1222@schroedinger.engr.sgi.com>
 <200511150434.15094.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: steiner@sgi.com, linux-mm@kvack.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

On Tue, 15 Nov 2005, Andi Kleen wrote:

> On Monday 14 November 2005 20:08, Christoph Lameter wrote:
> > I have thought about various ways to modify kmem_getpages() but these do 
> > not fit into the basic current concept of the slab allocator. The 
> > proposed method is the cleanest approach that I can think of. I'd be glad 
> > if you could come up with something different but AFAIK simply moving the 
> > policy application down in the slab allocator does not work.
> 
> I haven't checked all the details, but why can't it be done at the cache_grow
> layer? (that's already a slow path)

cache_grow is called only after the lists have been checked. Its the same
scenario as I described.

> If it's not possible to do it in the slow path I would say the design is 
> incompatible with interleaving then. Better not do it then than doing it wrong.

If MPOL_INTERLEAVE  is set then multiple kmalloc() invocations will 
allocate each item round robin on each node. That is the intended function 
of MPOL_INTERLEAVE right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
