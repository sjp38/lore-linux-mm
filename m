Date: Tue, 2 Oct 2007 17:06:07 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: kswapd min order, slub max order [was Re: -mm merge plans for 2.6.24]
In-Reply-To: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0710021646420.4916@blonde.wat.veritas.com>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chritoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Oct 2007, Andrew Morton wrote:
> #
> # slub && antifrag
> #
> have-kswapd-keep-a-minimum-order-free-other-than-order-0.patch
> only-check-absolute-watermarks-for-alloc_high-and-alloc_harder-allocations.patch
> slub-exploit-page-mobility-to-increase-allocation-order.patch
> slub-reduce-antifrag-max-order.patch
> 
>   I think this stuff is in the "mm stuff we don't want to merge" category. 
>   If so, I really should have dropped it ages ago.

I agree.  I spent a while last week bisecting down to see why my heavily
swapping loads take 30%-60% longer with -mm than mainline, and it was
here that they went bad.  Trying to keep higher orders free is costly.

On the other hand, hasn't SLUB efficiency been built on the expectation
that higher orders can be used?  And it would be a twisted shame for
high performance to be held back by some idiot's swapping load.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
