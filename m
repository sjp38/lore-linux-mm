Date: Mon, 17 Sep 2007 12:14:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix NUMA Memory Policy Reference Counting
In-Reply-To: <1190055637.5460.105.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709171212360.27769@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
 <1190055637.5460.105.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, eric.whitney@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007, Lee Schermerhorn wrote:

> Page allocation micro-benchmark:
> 
> Time to fault in 256K 16k pages [ia64] into a 4G anon segment.

You need to run this as a test that concurrently allocates these pages 
from as many processors as possible in a common address space. A single 
thread will not cause cache line bouncing. I suspect this will cause an 
additional issue than what we already have with mmap_sem locking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
