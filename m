Date: Fri, 9 May 2008 20:40:44 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/3] bootmem2 III
Message-ID: <20080509184044.GA19109@one.firstfloor.org>
References: <20080509151713.939253437@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080509151713.939253437@saeurebad.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, May 09, 2008 at 05:17:13PM +0200, Johannes Weiner wrote:
> here is bootmem2, a memory block-oriented boot time allocator.
> 
> Recent NUMA topologies broke the current bootmem's assumption that
> memory nodes provide non-overlapping and contiguous ranges of pages.

I'm still not sure that's a really good rationale for bootmem2.
e.g. the non continuous nodes are really special cases and there tends
to be enough memory at the beginning which is enough for boot time
use, so for those systems it would be quite reasonably to only 
put the continuous starts of the nodes into bootmem.

That said the bootmem code has gotten a little crufty and a clean
rewrite might be a good idea. 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
