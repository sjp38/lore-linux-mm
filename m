Date: Fri, 27 Jun 2003 16:22:21 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] My research agenda for 2.7
In-Reply-To: <200306271717.01562.phillips@arcor.de>
Message-ID: <Pine.LNX.4.53.0306271617210.21548@skynet>
References: <200306250111.01498.phillips@arcor.de> <200306271654.46491.phillips@arcor.de>
 <25700000.1056726277@[10.10.2.4]> <200306271717.01562.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jun 2003, Daniel Phillips wrote:

> On Friday 27 June 2003 17:04, Martin J. Bligh wrote:
> > Daniel Phillips <phillips@arcor.de> wrote (on Friday, June 27, 2003
> > > Some allocation strategies may be statistically more
> > > resistiant to fragmentation than others, but no allocator has been
> > > invented, or ever will be, that can guarantee that terminal fragmentation
> > > will never occur - only active defragmentation can provide such a
> > > guarantee.
> >
> > Whilst I agree with that in principle, it's inevitably expensive. Thus
> > whilst we may need to have that code, we should try to avoid using it ;-)
>
> That's exactly the idea.  Active defragmentation is just a fallback to handle
> currently-unhandled corner cases.  A good, efficient allocator that resists
> fragmentation in the first place is still needed.
>

I still suspect moving order0 allocations to slab will be a fragmentation
resistent allocator but my main concern would be that the slab allocator
overhead, both CPU and storage requirements will be too high.

On the other hand, it would do some things you are looking for. For
example, it allocates large blocks of memory in one lump and then
allocates them piecemeal. Second, it would be resistent to the FAFAFA
problem Martin pointed out. As slabs would be allocated in a large block
from the buddy, you are guarenteed that you'll be able to free up buddies.
Lastly, as there would be a cache specifically for userspace pages, a
defragger that looked exclusively at user pages will still be sure of
being able to free adjacent buddies.

I need to write a proper RFC.....

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
