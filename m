Subject: Re: kswapd min order, slub max order [was Re: -mm merge plans for
	2.6.24]
From: Mel Gorman <mel@csn.ul.ie>
In-Reply-To: <Pine.LNX.4.64.0710021646420.4916@blonde.wat.veritas.com>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0710021646420.4916@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Tue, 02 Oct 2007 19:38:53 +0100
Message-Id: <1191350333.2708.6.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chritoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-02 at 17:06 +0100, Hugh Dickins wrote:
> On Mon, 1 Oct 2007, Andrew Morton wrote:
> > #
> > # slub && antifrag
> > #
> > have-kswapd-keep-a-minimum-order-free-other-than-order-0.patch
> > only-check-absolute-watermarks-for-alloc_high-and-alloc_harder-allocations.patch
> > slub-exploit-page-mobility-to-increase-allocation-order.patch
> > slub-reduce-antifrag-max-order.patch
> > 
> >   I think this stuff is in the "mm stuff we don't want to merge" category. 
> >   If so, I really should have dropped it ages ago.
> 
> I agree.  I spent a while last week bisecting down to see why my heavily
> swapping loads take 30%-60% longer with -mm than mainline, and it was
> here that they went bad.  Trying to keep higher orders free is costly.
> 

Very interesting. I had agreed with these patches being pulled but it
was simply on the grounds that there was no agreement it was the right
thing to do. It was best to have mainline and -mm behave the same from a
fragmentation perspective and revisit this idea from scratch. That it
affects swapping loads is news so thanks for that.

> On the other hand, hasn't SLUB efficiency been built on the expectation
> that higher orders can be used?  And it would be a twisted shame for
> high performance to be held back by some idiot's swapping load.
> 

My belief is that SLUB can still use the higher orders if configured to
do so at boot-time. The loss of these patches means it won't try and do
it automatically. Christoph will chime in I'm sure.

-- 
Mel Gorman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
