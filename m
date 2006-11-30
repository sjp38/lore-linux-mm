Date: Wed, 29 Nov 2006 18:43:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
In-Reply-To: <456E3ACE.4040804@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0611291840120.19331@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
 <20061129082650.GB12734@infradead.org> <456D4722.2010202@yahoo.com.au>
 <Pine.LNX.4.64.0611291119480.16189@schroedinger.engr.sgi.com>
 <456E3ACE.4040804@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Hellwig <hch@infradead.org>, akpm@osdl.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006, Nick Piggin wrote:

> kmalloc.h uses the slab, and it calls kmem_cache_alloc. How could it be
> an improvement to not include slab.h? I don't think hiding a data type
> definition has any value, does it?

Well you argued yesterday (today?) for hiding struct kmem_cache in a 
opaque kmem_cache_t. Now its the other way around?

Maybe its best if I just straighten out slab.h (make a segment for the 
kmalloc material separate from the kmem_cache* functions and try to get 
the special slob definitions out by defining empty function ins slob.c? 

That will work for most of slob but not for the kmalloc portions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
