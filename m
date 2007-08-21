Date: Tue, 21 Aug 2007 13:59:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water marks
In-Reply-To: <46CB01B7.3050201@redhat.com>
Message-ID: <Pine.LNX.4.64.0708211355430.3082@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com> <46CB01B7.3050201@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Aug 2007, Rik van Riel wrote:

> Christoph Lameter wrote:
> 
> > 1. First reclaiming non dirty pages. Dirty pages are deferred until reclaim
> >    has reestablished the high marks. Then all the dirty pages (the laundry)
> >    is written out.
> 
> That sounds like a horrendously bad idea.  While one process
> is busy freeing all the non dirty pages, other processes can
> allocate those pages, leaving you with no memory to free up
> the dirty pages!

What is preventing that from occurring right now? If the dirty pags are 
aligned in the right way you can have the exact same situation.
 
> Also, writing out all the dirty pages at once seems like it
> could hurt latency quite badly, especially on large systems.

We only write back the dirty pages that we are about to reclaim not all of 
them. The bigger batching occurs if we go through multiple priorities. 
Plus writeback in the sync reclaim case is stopped if the device becomes 
contended anyways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
