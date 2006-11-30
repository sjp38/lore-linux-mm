Message-ID: <456E53B2.9020701@yahoo.com.au>
Date: Thu, 30 Nov 2006 14:44:50 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com> <20061129082650.GB12734@infradead.org> <456D4722.2010202@yahoo.com.au> <Pine.LNX.4.64.0611291119480.16189@schroedinger.engr.sgi.com> <456E3ACE.4040804@yahoo.com.au> <Pine.LNX.4.64.0611291840120.19331@schroedinger.engr.sgi.com> <456E4A53.2030000@yahoo.com.au> <Pine.LNX.4.64.0611291937560.19557@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611291937560.19557@schroedinger.engr.sgi.com>
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
>>I don't see the problem with slab/slob. It is not the nicest code, but it
>>isn't unreadable. We do something very similar with nommu, for (perhaps
>>not the best!) example.
> 
> 
> I need some order in there to add another type of slab allocator without 
> getting into an umaintainable mess.

OK, slab_defs.h and slob_defs.h would work, wouldn't it? That seems to be
the standard pattern used when alternatives become too numerous / complex
to be in a single file.

>>But kmalloc seems like one thing that could be split nicely. It would
>>allow you to get rid of asm/page.h and asm/cache.h from slab.h
>>(converting callers would be a bigger job).
> 
> 
> What callers would need to be converted?

When you remove kmalloc.h from slab.h? I guess anyone that includes
slab.h in order to get kmalloc.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
