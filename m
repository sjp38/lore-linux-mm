Date: Wed, 12 Jan 2005 23:03:14 -0800
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC] Avoiding fragmentation through different allocator
Message-ID: <20050113070314.GL2995@waste.org>
References: <Pine.LNX.4.58.0501122101420.13738@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0501122101420.13738@skynet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 12, 2005 at 09:09:24PM +0000, Mel Gorman wrote:
> I stress-tested this patch very heavily and it never oopsed so I am
> confident of it's stability, so what is left is to look at the results of
> this patch were and I think they look promising in a number of respects. I
> have graphs that do not translate to text very well, so I'll just point you
> to http://www.csn.ul.ie/~mel/projects/mbuddy-results-1 instead.

This graph rather hard to comprehend.

> The results were not spectacular but still very interesting. Under heavy
> stresing (updatedb + 4 simultaneous -j4 kernel compiles with avg load 15)
> fragmentation is consistently lower than the standard allocator. It could
> also be a lot better if there was some means of purging caches, userpages
> and buffers but thats in the future. For the moment, the only real control
> I had was the buffer pages.

You might stress higher order page allocation with a) 8k stacks turned
on b) UDP NFS with large read/write.
 
> Opinions/Feedback?

Looks interesting.

-- 
Mathematics is the supreme nostalgia of our time.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
