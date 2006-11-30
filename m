Date: Wed, 29 Nov 2006 19:39:31 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
In-Reply-To: <456E4A53.2030000@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0611291937560.19557@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
 <20061129082650.GB12734@infradead.org> <456D4722.2010202@yahoo.com.au>
 <Pine.LNX.4.64.0611291119480.16189@schroedinger.engr.sgi.com>
 <456E3ACE.4040804@yahoo.com.au> <Pine.LNX.4.64.0611291840120.19331@schroedinger.engr.sgi.com>
 <456E4A53.2030000@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Hellwig <hch@infradead.org>, akpm@osdl.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006, Nick Piggin wrote:

> I don't see the problem with slab/slob. It is not the nicest code, but it
> isn't unreadable. We do something very similar with nommu, for (perhaps
> not the best!) example.

I need some order in there to add another type of slab allocator without 
getting into an umaintainable mess.

> But kmalloc seems like one thing that could be split nicely. It would
> allow you to get rid of asm/page.h and asm/cache.h from slab.h
> (converting callers would be a bigger job).

What callers would need to be converted?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
