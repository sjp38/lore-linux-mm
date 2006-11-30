Date: Wed, 29 Nov 2006 19:50:32 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
In-Reply-To: <456E53B2.9020701@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0611291946320.19578@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
 <20061129082650.GB12734@infradead.org> <456D4722.2010202@yahoo.com.au>
 <Pine.LNX.4.64.0611291119480.16189@schroedinger.engr.sgi.com>
 <456E3ACE.4040804@yahoo.com.au> <Pine.LNX.4.64.0611291840120.19331@schroedinger.engr.sgi.com>
 <456E4A53.2030000@yahoo.com.au> <Pine.LNX.4.64.0611291937560.19557@schroedinger.engr.sgi.com>
 <456E53B2.9020701@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Hellwig <hch@infradead.org>, akpm@osdl.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006, Nick Piggin wrote:

> OK, slab_defs.h and slob_defs.h would work, wouldn't it? That seems to be
> the standard pattern used when alternatives become too numerous / complex
> to be in a single file.

Maybe better define a standard API and provide empty functions for slob?

I think it would be feasable to have all slab allocators work within the 
same kmem_cache_* framework. The kmalloc approaches are all different 
though. So i would need kmalloc_slob and kmalloc_slab?

> > What callers would need to be converted?
> 
> When you remove kmalloc.h from slab.h? I guess anyone that includes
> slab.h in order to get kmalloc.

Well so far I have included kmalloc.h from slab.h for backward 
compatibility reasons in order to avoid that. That allows a gradual 
transition to kmalloc.h for files only needing kmalloc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
