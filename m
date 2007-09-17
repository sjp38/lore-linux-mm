Subject: Re: [PATCH] Fix NUMA Memory Policy Reference Counting
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0709171212360.27769@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <1190055637.5460.105.camel@localhost>
	 <Pine.LNX.4.64.0709171212360.27769@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 17 Sep 2007 15:38:05 -0400
Message-Id: <1190057885.5460.134.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, eric.whitney@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-09-17 at 12:14 -0700, Christoph Lameter wrote:
> On Mon, 17 Sep 2007, Lee Schermerhorn wrote:
> 
> > Page allocation micro-benchmark:
> > 
> > Time to fault in 256K 16k pages [ia64] into a 4G anon segment.
> 
> You need to run this as a test that concurrently allocates these pages 
> from as many processors as possible in a common address space. A single 
> thread will not cause cache line bouncing. I suspect this will cause an 
> additional issue than what we already have with mmap_sem locking.
> 
Yeah, I'll have to write a custom, multithreaded test for this, or
enhance memtoy to attach shm segments by id and run lots of them
together.  I'll try to get to it asap.  

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
