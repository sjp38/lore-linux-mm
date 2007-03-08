Date: Thu, 8 Mar 2007 13:54:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 0/3] SLUB: The unqueued slab allocator V4
In-Reply-To: <20070308174004.GB12958@skynet.ie>
Message-ID: <Pine.LNX.4.64.0703081135280.3130@schroedinger.engr.sgi.com>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0703081022040.1615@skynet.skynet.ie>
 <Pine.LNX.4.64.0703080836300.27191@schroedinger.engr.sgi.com>
 <20070308174004.GB12958@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

Note that I am amazed that the kernbench even worked. On small machine I 
seem to be getting into trouble with order 1 allocations. SLAB seems to be 
able to avoid the situation by keeping higher order pages on a freelist 
and reduce the alloc/frees of higher order pages that the page allocator
has to deal with. Maybe we need per order queues in the page allocator? 

There must be something fundamentally wrong in the page allocator if the 
SLAB queues fix this issue. I was able to fix the issue in V5 by forcing 
SLUB to keep a mininum number of objects around regardless of the fit to
a page order page. Pass through is deadly since the crappy page allocator 
cannot handle it.

Higher order page allocation failures can be avoided by using kmalloc. 
Yuck! Hopefully your patches fix that fundamental problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
