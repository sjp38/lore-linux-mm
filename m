Received: from bowery.psl.cs.columbia.edu (bowery.psl.cs.columbia.edu [128.59.23.43])
	by cs.columbia.edu (8.9.1/8.9.1) with ESMTP id FAA17725
	for <linux-mm@kvack.org>; Thu, 9 Dec 1999 05:21:26 -0500 (EST)
Received: from bowery.psl.cs.columbia.edu (localhost [127.0.0.1])
	by bowery.psl.cs.columbia.edu (8.9.3/8.9.3) with ESMTP id FAA21828
	for <linux-mm@kvack.org>; Thu, 9 Dec 1999 05:21:48 -0500
Message-Id: <199912091021.FAA21828@bowery.psl.cs.columbia.edu>
From: Chris Vaill <cvaill@cs.columbia.edu>
Subject: Motivation for page replace alg.?
Date: Thu, 09 Dec 1999 05:21:47 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm a kernel newbie, and I apologize if my question is answered by
easily accessible docs, but I couldn't find any such answers in my
search.

I've been looking into the swap out routines, and in particular their
behavior when faced with several competing processes aggressively
allocating and using memory (more memory, collectively, than is
physically available).  I've found that this results in repeated
drastic swings in rss for each process over time.

As far as I can tell, this results from the way swap_cnt is separated
from rss.  A victim process is chosen because it has the highest
swap_cnt, but as its rss falls, the swap_cnt stays high, so the same
victim process is chosen over and over again until no more pages can
be swapped from that process, and swap_cnt is zeroed.  From my (very
naive) perspective, it seems that always choosing the same victim
process for swapping would not result in a good approximation of LRU.

My questions are, is my read of the code correct here, and is this the
intended behavior of the page replacement algorithm?  If so, what is
the motivation?  Is this based on some existing mm research, or
informal observation and testing, or something else entirely?

I've heard it mentioned that the swap routines were not meant to deal
with trashing procs, which is basically what I am testing here.
Obviously the swap routines work pretty well for normal, well-behaved
procs; I'm just trying to get a little insight into the design process
here.

Thanks for any info or pointers anyone can provide.

-Chris

P.S. I did my testing on 2.2.13, but it is my understanding that the
algorithm is the same in the 2.3 kernels.  Smack me if this is not the
case.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
