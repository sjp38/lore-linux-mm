Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA32244
	for <linux-mm@kvack.org>; Tue, 22 Dec 1998 16:51:05 -0500
Date: Tue, 22 Dec 1998 21:10:57 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <Pine.LNX.3.96.981222162525.8801A-100000@laser.bogus>
Message-ID: <Pine.LNX.4.03.9812222107211.397-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Dec 1998, Andrea Arcangeli wrote:
> On 22 Dec 1998, Eric W. Biederman wrote:
> 
> >My suggestion (again) would be to not call shrink_mmap in the swapper
> >(unless we are endangering atomic allocations).  And to never call
> >swap_out in the memory allocator (just wake up kswapd).
> 
> Ah, I just had your _same_ _exactly_ idea yesterday but there' s a
> good reason I nor proposed/tried it. The point are Real time
> tasks. kswapd is not realtime and a realtime task must be able to
> swapout a little by itself in try_to_free_pages() when there's
> nothing to free on the cache anymore.

- kswapd should make sure that there is enough on the cache
  (we should keep track of how many 1-count cache pages there
  are in the system)
- realtime tasks shouldn't go around allocating huge amounts
  of memory -- this totally ruins the realtime aspect anyway

> (and this will avoid also tasks other than kswapd to
> sleep waiting for slowww SYNC IO). 

Some tasks (really big memory hogs) are better left sleeping
for I/O because they otherwise completely overpower the rest
of the system. But that's a slightly different story :)

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
