Date: Thu, 13 Jan 2005 10:22:13 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] Avoiding fragmentation through different allocator
In-Reply-To: <20050113070314.GL2995@waste.org>
Message-ID: <Pine.LNX.4.58.0501131011390.31154@skynet>
References: <Pine.LNX.4.58.0501122101420.13738@skynet> <20050113070314.GL2995@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jan 2005, Matt Mackall wrote:

> On Wed, Jan 12, 2005 at 09:09:24PM +0000, Mel Gorman wrote:
> > I stress-tested this patch very heavily and it never oopsed so I am
> > confident of it's stability, so what is left is to look at the results of
> > this patch were and I think they look promising in a number of respects. I
> > have graphs that do not translate to text very well, so I'll just point you
> > to http://www.csn.ul.ie/~mel/projects/mbuddy-results-1 instead.
>
> This graph rather hard to comprehend.
>

There is not a lot of ways to illustrate how pages are allocated
throughout an address space. If you have a better suggestion, I can update
the relevant tool.

> > The results were not spectacular but still very interesting. Under heavy
> > stresing (updatedb + 4 simultaneous -j4 kernel compiles with avg load 15)
> > fragmentation is consistently lower than the standard allocator. It could
> > also be a lot better if there was some means of purging caches, userpages
> > and buffers but thats in the future. For the moment, the only real control
> > I had was the buffer pages.
>
> You might stress higher order page allocation with a) 8k stacks turned
> on b) UDP NFS with large read/write.
>

CONFIG_4KSTACKS is not set on my system so I'm already using 8k stacks.
Based on Trond's mail, I checked my network and the MTU is 1500 bytes so I
don't think I can force high-order allocations there.

Also, while I agree this test would be important, I think it'll be way
more important when there is something in place that actually tries to
free up high-order blocks and then compare.

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
