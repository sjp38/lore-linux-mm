Date: Mon, 2 Sep 2002 22:35:13 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: About the free page pool
In-Reply-To: <3D740C35.9E190D04@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209022233590.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Scott Kaplan <sfkaplan@cs.amherst.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Sep 2002, Andrew Morton wrote:

> The most important are 1-order allocations (8k, for kernel stacks).
> The memory allocator will retry these allocations indefinitely, so
> they end up succeeding, somehow.
>
> I think there's a bug in there, actually.  If all zones have enough
> free memory but there are no 1-order pages available, then the 1-order
> allocator tried to run page reclaim, which will say "nope, nothing
> needs doing".  Eventually, someone else returns some memory and coalescing
> happens.   It's not a very glorious part of the kernel design.

This is fixable with rmap, though.  Another old item on my TODO list. ;(


regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
