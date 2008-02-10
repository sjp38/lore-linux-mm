Date: Sat, 9 Feb 2008 19:36:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB tbench regression due to page allocator deficiency
In-Reply-To: <20080210024517.GA32721@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0802091931390.14073@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
 <20080209143518.ced71a48.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com>
 <20080210024517.GA32721@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Sun, 10 Feb 2008, Nick Piggin wrote:

> What kind of allocating and freeing of pages are you talking about? Are
> you just measuring single threaded performance?

The tests that I did do measure a couple of scenarios. tbench seems to 
free/release page size chunks quite a bit and benefits from SLAB queueing
up the pages. tbench stays on each processor it seems, so very limited 
contention effects. The page allocator problem is simply caused by too
many instructions that need to run in order to get a page.

> Other things you can do like not looking at the watermarks if the zone
> has pcp pages avoids cacheline bouncing on SMP. 
> 
> I had a set of patches do to various little optimisations like that, but
> I don't actually know if they would help you significantly or not.
> 
> I could try a bit of profiling if you tell me what specific test you
> are interested in?

Run tbench with SLUB and tbench will hit the page allocator hard with 
page sized allocations. If you apply the patch that I provided in this 
thread then these will go away. SLUB will reduce the load on the page 
allocator like SLAB. The SLUB fastpath will stand in for the page 
allocator fastpath.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
