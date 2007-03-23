Date: Fri, 23 Mar 2007 08:08:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
In-Reply-To: <20070322234848.100abb3d.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0703230804120.21857@schroedinger.engr.sgi.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
 <20070322223927.bb4caf43.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com>
 <20070322234848.100abb3d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Mar 2007, Andrew Morton wrote:

> > About 40% on fork+exit. See 
> > 
> > http://marc.info/?l=linux-ia64&m=110942798406005&w=2
> > 
> 
> afacit that two-year-old, totally-different patch has nothing to do with my
> repeatedly-asked question.  It appears to be consolidating three separate
> quicklist allocators into one common implementation.

Yes it shows the performance gains from the quicklist approach. This the 
work Robin Holt did on the problem. The problem is how to validate the 
patch because there should be no change at all on ia64 and on i386 we 
basically measure the overhead of the slab allocations. One could 
measure the impact x86_64 because this introduces quicklists to that 
platform.

The earlier discussion focused on avoiding zeroing of pte as far as I can 
recall.
 
> but it crashes early in the page allocator (i386) and I don't see why.  It
> makes me wonder if we have a use-after-free which is hidden by the presence
> of the quicklist buffering or something.

This was on i386? Could be hidden now by the slab use ther.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
