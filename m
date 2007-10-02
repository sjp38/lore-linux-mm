From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: kswapd min order, slub max order [was Re: -mm merge plans for 2.6.24]
Date: Tue, 2 Oct 2007 19:10:58 +1000
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org> <Pine.LNX.4.64.0710021646420.4916@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0710021646420.4916@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710021910.58983.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chritoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 03 October 2007 02:06, Hugh Dickins wrote:
> On Mon, 1 Oct 2007, Andrew Morton wrote:
> > #
> > # slub && antifrag
> > #
> > have-kswapd-keep-a-minimum-order-free-other-than-order-0.patch
> > only-check-absolute-watermarks-for-alloc_high-and-alloc_harder-allocation
> >s.patch slub-exploit-page-mobility-to-increase-allocation-order.patch
> > slub-reduce-antifrag-max-order.patch
> >
> >   I think this stuff is in the "mm stuff we don't want to merge"
> > category. If so, I really should have dropped it ages ago.
>
> I agree.  I spent a while last week bisecting down to see why my heavily
> swapping loads take 30%-60% longer with -mm than mainline, and it was
> here that they went bad.  Trying to keep higher orders free is costly.

Yeah, no there's no way we'd merge that.


> On the other hand, hasn't SLUB efficiency been built on the expectation
> that higher orders can be used?  And it would be a twisted shame for
> high performance to be held back by some idiot's swapping load.

IMO it's a bad idea to create all these dependencies like this.

If SLUB can get _more_ performance out of using higher order allocations,
then fine. If it is starting off at a disadvantage at the same order, then it
that should be fixed first, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
