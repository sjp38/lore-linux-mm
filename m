Received: from aa.eps.jhu.edu (aa.eps.jhu.edu [128.220.24.92])
 by jhmail.hcf.jhu.edu (PMDF V5.2-31 #37929)
 with ESMTP id <01JJAUVWS8AWFANY9M@jhmail.hcf.jhu.edu> for linux-mm@kvack.org;
 Thu, 9 Dec 1999 14:39:00 EDT
Date: Thu, 09 Dec 1999 14:37:39 -0500 (EST)
From: afei@jhu.edu
Subject: Re: Motivation for page replace alg.?
In-reply-to: <199912091021.FAA21828@bowery.psl.cs.columbia.edu>
Message-id: <Pine.GSO.4.05.9912091421250.11647-100000@aa.eps.jhu.edu>
MIME-version: 1.0
Content-type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Vaill <cvaill@cs.columbia.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chris, we have done some analysis on this problem. Please check out the
online document about linux memory management at:
http://aa.eps.jhu.edu/~feiliu/Linux

sorry about the readability, it is converted from word. I will work on the
layout later, but the content is there.

Fei
On Thu, 9 Dec 1999, Chris Vaill wrote:

> I'm a kernel newbie, and I apologize if my question is answered by
> easily accessible docs, but I couldn't find any such answers in my
> search.
> 
> I've been looking into the swap out routines, and in particular their
> behavior when faced with several competing processes aggressively
> allocating and using memory (more memory, collectively, than is
> physically available).  I've found that this results in repeated
> drastic swings in rss for each process over time.
> 
> As far as I can tell, this results from the way swap_cnt is separated
> from rss.  A victim process is chosen because it has the highest
> swap_cnt, but as its rss falls, the swap_cnt stays high, so the same
> victim process is chosen over and over again until no more pages can
> be swapped from that process, and swap_cnt is zeroed.  From my (very
> naive) perspective, it seems that always choosing the same victim
> process for swapping would not result in a good approximation of LRU.
> 
> My questions are, is my read of the code correct here, and is this the
> intended behavior of the page replacement algorithm?  If so, what is
> the motivation?  Is this based on some existing mm research, or
> informal observation and testing, or something else entirely?
> 
> I've heard it mentioned that the swap routines were not meant to deal
> with trashing procs, which is basically what I am testing here.
> Obviously the swap routines work pretty well for normal, well-behaved
> procs; I'm just trying to get a little insight into the design process
> here.
> 
> Thanks for any info or pointers anyone can provide.
> 
> -Chris
> 
> P.S. I did my testing on 2.2.13, but it is my understanding that the
> algorithm is the same in the 2.3 kernels.  Smack me if this is not the
> case.
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://humbolt.geo.uu.nl/Linux-MM/
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
