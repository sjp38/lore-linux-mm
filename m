Date: Wed, 13 Feb 2008 12:09:18 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Fastpath prototype?
In-Reply-To: <47B2D6AB.1020408@suse.de>
Message-ID: <Pine.LNX.4.64.0802131208470.19775@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
 <20080211235607.GA27320@wotan.suse.de> <Pine.LNX.4.64.0802112205150.26977@schroedinger.engr.sgi.com>
 <200802121140.12040.ak@suse.de> <Pine.LNX.4.64.0802121208150.2120@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0802121426060.9829@schroedinger.engr.sgi.com> <47B2D6AB.1020408@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2008, Andi Kleen wrote:

> > tbench/SLUB:  726.25 MB/sec
> > 
> > Even adding the fast path prototype (covers only slab allocs >=4K 
> > allocs) yields only 1825.68 MB/sec
> 
> So why is the new fast path slower than the old one? Because it is not
> NUMA aware?

No because it only covers kmalloc-4096 and nothing else. All other 
allocations go to the now queueless page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
