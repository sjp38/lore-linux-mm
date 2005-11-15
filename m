From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Make the slab allocator observe NUMA policies
Date: Tue, 15 Nov 2005 17:51:39 +0100
References: <Pine.LNX.4.62.0511101401390.16481@schroedinger.engr.sgi.com> <200511150434.15094.ak@suse.de> <Pine.LNX.4.62.0511150841150.9258@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0511150841150.9258@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511151751.40035.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: steiner@sgi.com, linux-mm@kvack.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

On Tuesday 15 November 2005 17:43, Christoph Lameter wrote:
> On Tue, 15 Nov 2005, Andi Kleen wrote:
> > On Monday 14 November 2005 20:08, Christoph Lameter wrote:
> > > I have thought about various ways to modify kmem_getpages() but these
> > > do not fit into the basic current concept of the slab allocator. The
> > > proposed method is the cleanest approach that I can think of. I'd be
> > > glad if you could come up with something different but AFAIK simply
> > > moving the policy application down in the slab allocator does not work.
> >
> > I haven't checked all the details, but why can't it be done at the
> > cache_grow layer? (that's already a slow path)
>
> cache_grow is called only after the lists have been checked. Its the same
> scenario as I described.

So retry the check?

>
> > If it's not possible to do it in the slow path I would say the design is
> > incompatible with interleaving then. Better not do it then than doing it
> > wrong.
>
> If MPOL_INTERLEAVE  is set then multiple kmalloc() invocations will
> allocate each item round robin on each node. That is the intended function
> of MPOL_INTERLEAVE right?

memory policy was always only designed to work on pages, not on smaller
objects. So no.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
