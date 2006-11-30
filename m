Message-ID: <456E5B9C.6030504@yahoo.com.au>
Date: Thu, 30 Nov 2006 15:18:36 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com> <20061129082650.GB12734@infradead.org> <456D4722.2010202@yahoo.com.au> <Pine.LNX.4.64.0611291119480.16189@schroedinger.engr.sgi.com> <456E3ACE.4040804@yahoo.com.au> <Pine.LNX.4.64.0611291840120.19331@schroedinger.engr.sgi.com> <456E4A53.2030000@yahoo.com.au> <Pine.LNX.4.64.0611291937560.19557@schroedinger.engr.sgi.com> <456E53B2.9020701@yahoo.com.au> <Pine.LNX.4.64.0611291946320.19578@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611291946320.19578@schroedinger.engr.sgi.com>
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
>>OK, slab_defs.h and slob_defs.h would work, wouldn't it? That seems to be
>>the standard pattern used when alternatives become too numerous / complex
>>to be in a single file.
> 
> 
> Maybe better define a standard API and provide empty functions for slob?

There is a standard API, isn't there? It is the API used by the callers.
Ie. the one in slab.h, before slob came along.

So yes, we *have* to have all allocators using the same kmem_cache_t
framework. I don't see how a different API between slab and slob could
work?

> I think it would be feasable to have all slab allocators work within the 
> same kmem_cache_* framework. The kmalloc approaches are all different 
> though. So i would need kmalloc_slob and kmalloc_slab?

I see, I didn't realise kmalloc was different as well. I guess you could
follow the same approach. Probably don't bother splitting it, and just
move the kmalloc definitions to slab_defs.h / slob_defs.h?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
