Date: Wed, 29 Nov 2006 08:26:50 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
Message-ID: <20061129082650.GB12734@infradead.org>
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 27, 2006 at 10:33:28PM -0800, Christoph Lameter wrote:
> slab.h really defines multiple APIs. One is the classic slab api
> where one can define a slab cache by specifying exactly how
> the slab has to be generated. This API is not frequently used.
> 
> Another is the kmalloc API. Quite a number of kernel source code files 
> need kmalloc but do not need to generate custom slabs. The kmalloc API 
> also use some funky macros that may be better isolated in an additional .h 
> file in order to ease future cleanup. Make kmalloc.h self contained by 
> adding two extern definitions local to kmalloc and kmalloc_node.
> 
> Then there is the SLOB api mixed in with slab. Take that out and define it 
> in its own header file.

NACK.  This is utterly braindead, easily shown by things like the need
to duplicate the kmem_cache_alloc prototype.

What are you trying to solve with this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
