Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA05115
	for <linux-mm@kvack.org>; Wed, 23 Dec 1998 14:05:31 -0500
Date: Wed, 23 Dec 1998 09:45:41 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <Pine.LNX.3.96.981222233250.377B-100000@laser.bogus>
Message-ID: <Pine.LNX.4.03.9812230941350.9469-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Dec 1998, Andrea Arcangeli wrote:
> On Tue, 22 Dec 1998, Rik van Riel wrote:
> 
> >- kswapd should make sure that there is enough on the cache
> >  (we should keep track of how many 1-count cache pages there
> >  are in the system)
> >- realtime tasks shouldn't go around allocating huge amounts
> >  of memory -- this totally ruins the realtime aspect anyway
> 
> What about if there is netscape iconized and the realtime task want to
> allocate some memory to mlock it but has to swapout netscape to do that?

When the realtime task is still setting up it's resources, it's
not yet busy with it's real task and shouldn't be considered RT
yet -- but I agree with your general idea that tasks should be
able to swap_out() too in emergencies...

> >> (and this will avoid also tasks other than kswapd to
> >> sleep waiting for slowww SYNC IO). 
> >
> >Some tasks (really big memory hogs) are better left sleeping
> >for I/O because they otherwise completely overpower the rest
> >of the system. But that's a slightly different story :)
> 
> The point here is that `free` get blocked on I/O because the
> malicious process is trashing VM.

No, the idea is that the big task is swap_out()ing itself
when it exceeds it's RSS limit _and_ the systemwide RSS
'thrash' limit is exceeded.

With the current (independant swap cache freeing) scheme,
RSS limits are fairly unobtrusive and only give noticable
overhead when the rest of the system would have been
bothered anyway.

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
