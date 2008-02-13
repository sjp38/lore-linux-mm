Message-ID: <47B2D6AB.1020408@suse.de>
Date: Wed, 13 Feb 2008 12:38:19 +0100
From: Andi Kleen <ak@suse.de>
MIME-Version: 1.0
Subject: Re: Fastpath prototype?
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com> <20080211235607.GA27320@wotan.suse.de> <Pine.LNX.4.64.0802112205150.26977@schroedinger.engr.sgi.com> <200802121140.12040.ak@suse.de> <Pine.LNX.4.64.0802121208150.2120@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0802121426060.9829@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802121426060.9829@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Here is a patch to remove the pcp lists (just in case someone wants to toy 
> around with these things too). It hits tbench/SLUB badly because that 
> relies heavily on effective caching by the page allocator
> 
> tbench/SLUB:  726.25 MB/sec
> 
> Even adding the fast path prototype (covers only slab allocs >=4K 
> allocs) yields only 1825.68 MB/sec

So why is the new fast path slower than the old one? Because it is not
NUMA aware?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
