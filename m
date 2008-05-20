Date: Tue, 20 May 2008 12:16:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to
 ksize().
In-Reply-To: <1211310896.18026.214.camel@calx>
Message-ID: <Pine.LNX.4.64.0805201215330.11020@schroedinger.engr.sgi.com>
References: <20080520095935.GB18633@linux-sh.org>  <2373.1211296724@redhat.com>
  <Pine.LNX.4.64.0805200944210.6135@schroedinger.engr.sgi.com>
 <1211307820.18026.190.camel@calx>  <Pine.LNX.4.64.0805201149270.10868@schroedinger.engr.sgi.com>
  <1211310023.18026.210.camel@calx>  <Pine.LNX.4.64.0805201206040.10964@schroedinger.engr.sgi.com>
 <1211310896.18026.214.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: David Howells <dhowells@redhat.com>, Paul Mundt <lethal@linux-sh.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 May 2008, Matt Mackall wrote:

> > How would that work given that both SLUB and SLOB forward >4k allocs to 
> > the page allocator? So any compound page allocation may be a slab 
> > allocation. Is there some way to distinguish between a 
> > allocations of the page allocator and a slab alloc?
> 
> We can't do it at all for SLOB. But when debugging is turned on, we can
> notice (in SLAB and SLUB) whenever anyone asks for the ksize() of
> something that lives on a non-kmalloc slab.

We could mark the pages specially I guess. Add a slab flag for 
kmalloc? PageSlab and PageKmalloc?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
