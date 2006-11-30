Message-ID: <456E4A53.2030000@yahoo.com.au>
Date: Thu, 30 Nov 2006 14:04:51 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com> <20061129082650.GB12734@infradead.org> <456D4722.2010202@yahoo.com.au> <Pine.LNX.4.64.0611291119480.16189@schroedinger.engr.sgi.com> <456E3ACE.4040804@yahoo.com.au> <Pine.LNX.4.64.0611291840120.19331@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611291840120.19331@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, akpm@osdl.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 30 Nov 2006, Nick Piggin wrote:
> 
> 
>>kmalloc.h uses the slab, and it calls kmem_cache_alloc. How could it be
>>an improvement to not include slab.h? I don't think hiding a data type
>>definition has any value, does it?
> 
> 
> Well you argued yesterday (today?) for hiding struct kmem_cache in a 
> opaque kmem_cache_t. Now its the other way around?

No. I meant that the kmem_cache_t * slab handle that callers get *is*
opaque, as far as they are concerned -- so I wondered what other reasons
there were to remove the typedef.

The enforced hiding of struct kmem_cache is a fun trick, but it is not
something we care about in other parts of the kernel.

> Maybe its best if I just straighten out slab.h (make a segment for the 
> kmalloc material separate from the kmem_cache* functions and try to get 
> the special slob definitions out by defining empty function ins slob.c? 

I don't see the problem with slab/slob. It is not the nicest code, but it
isn't unreadable. We do something very similar with nommu, for (perhaps
not the best!) example.

> That will work for most of slob but not for the kmalloc portions.

But kmalloc seems like one thing that could be split nicely. It would
allow you to get rid of asm/page.h and asm/cache.h from slab.h
(converting callers would be a bigger job).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
