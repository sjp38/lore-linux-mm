Date: Wed, 16 May 2001 14:10:43 -0400
From: Alfred Perlstein <bright@rush.net>
Subject: Re: on load control / process swapping
Message-ID: <20010516141042.I12365@superconductor.rush.net>
References: <200105161714.f4GHEFs72217@earth.backplane.com> <Pine.LNX.4.33.0105161439140.18102-100000@duckman.distro.conectiva> <20010516135707.H12365@superconductor.rush.net> <200105161801.f4GI1Oc73283@earth.backplane.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200105161801.f4GI1Oc73283@earth.backplane.com>; from dillon@earth.backplane.com on Wed, May 16, 2001 at 11:01:24AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Charles Randall <crandall@matchlogic.com>, Roger Larsson <roger.larsson@norran.net>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

* Matt Dillon <dillon@earth.backplane.com> [010516 14:01] wrote:
> 
>     I think someone tried to implement O_DIRECT a while back, but it
>     was fairly complex to try to do away with caching entirely.
> 
>     I think our best bet to 'start' an implementation of O_DIRECT is
>     to support the flag in open() and fcntl(), and have it simply
>     modify the sequential detection heuristic to throw away pages
>     and buffers rather then simply depressing their priority.

yes, as i said:

> :A simple solution would involve passing along flags such that if
> :the IO occurs to a non-previously-cached page the buf/page is
> :immediately placed on the free list upon completion.  That way the
> :next IO can pull the now useless bufferspace from the freelist.
> :
> :Basically you add another buffer queue for "throw away" data that
> :exists as a "barely cached" queue.  This way your normal data
> :doesn't compete on the LRU with non-cached data.
> 
>     Eventually we can implement the direct-I/O piece of the equation.
> 
>     I could do this first part in an hour, I think.  When I get home....

Thank you.

-Alfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
