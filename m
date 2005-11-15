Date: Tue, 15 Nov 2005 08:55:52 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] Make the slab allocator observe NUMA policies
In-Reply-To: <200511151751.40035.ak@suse.de>
Message-ID: <Pine.LNX.4.62.0511150853010.9797@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511101401390.16481@schroedinger.engr.sgi.com>
 <200511150434.15094.ak@suse.de> <Pine.LNX.4.62.0511150841150.9258@schroedinger.engr.sgi.com>
 <200511151751.40035.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: steiner@sgi.com, linux-mm@kvack.org, alokk@calsoftinc.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Nov 2005, Andi Kleen wrote:

> > > I haven't checked all the details, but why can't it be done at the
> > > cache_grow layer? (that's already a slow path)
> >
> > cache_grow is called only after the lists have been checked. Its the same
> > scenario as I described.
> 
> So retry the check?

The checks are quit extensive there is locking going on etc. No easy way 
back. And this is easily going to offset what you see as negative in the 
proposed patch.

> > > If it's not possible to do it in the slow path I would say the design is
> > > incompatible with interleaving then. Better not do it then than doing it
> > > wrong.
> >
> > If MPOL_INTERLEAVE  is set then multiple kmalloc() invocations will
> > allocate each item round robin on each node. That is the intended function
> > of MPOL_INTERLEAVE right?
> 
> memory policy was always only designed to work on pages, not on smaller
> objects. So no.

memory policy works on huge pages in SLES9, so it already works on larger 
objects. Why should it not also work on smaller objects?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
