Date: Fri, 27 Jun 2003 08:04:39 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC] My research agenda for 2.7
Message-ID: <25700000.1056726277@[10.10.2.4]>
In-Reply-To: <200306271654.46491.phillips@arcor.de>
References: <200306250111.01498.phillips@arcor.de> <Pine.LNX.4.53.0306271345330.14677@skynet> <23430000.1056725030@[10.10.2.4]> <200306271654.46491.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Daniel Phillips <phillips@arcor.de> wrote (on Friday, June 27, 2003 16:54:46 +0200):

> On Friday 27 June 2003 16:43, Martin J. Bligh wrote:
>> The buddy allocator is not a good system for getting rid of fragmentation.
> 
> We've talked in the past about throwing out the buddy allocator and adopting 
> something more modern and efficient and I hope somebody will actually get 
> around to doing that.  In any event, defragging is an orthogonal issue.  Some 
> allocation strategies may be statistically more resistiant to fragmentation 
> than others, but no allocator has been invented, or ever will be, that can 
> guarantee that terminal fragmentation will never occur - only active 
> defragmentation can provide such a guarantee.

Whilst I agree with that in principle, it's inevitably expensive. Thus 
whilst we may need to have that code, we should try to avoid using it ;-)

The buddy allocator is obviously flawed in this department ... strategies
like allocating a 4M block to a process up front, then allocing out of that
until we're low on mem, then reclaiming in as large blocks as possible from
those process caches, etc, etc, would obviously help too. Though maybe
we're just permanently low on mem after a while, so it'd be better to just
group pagecache pages together ... that would actually be pretty simple to
change ... hmmm.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
