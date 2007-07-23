Date: Mon, 23 Jul 2007 16:17:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] add __GFP_ZERO to GFP_LEVEL_MASK
In-Reply-To: <1185190711.8197.15.camel@twins>
Message-ID: <Pine.LNX.4.64.0707231615310.427@schroedinger.engr.sgi.com>
References: <1185185020.8197.11.camel@twins>  <20070723112143.GB19437@skynet.ie>
 <1185190711.8197.15.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jul 2007, Peter Zijlstra wrote:

> ---
> Daniel recently spotted that __GFP_ZERO is not (and has never been)
> part of GFP_LEVEL_MASK. I could not find a reason for this in the
> original patch: 3977971c7f09ce08ed1b8d7a67b2098eb732e4cd in the -bk
> tree.
> 
> This of course is in stark contradiction with the comment accompanying
> GFP_LEVEL_MASK.

NACK.

The effect that this patch will have is that __GFP_ZERO is passed through 
to the page allocator which will needlessly zero pages. GFP_LEVEL_MASK is 
used to filter out the flags that are to be passed to the page allocator. 
__GFP_ZERO is not passed on but handled by the slab allocators.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
