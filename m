Date: Fri, 11 Dec 1998 10:54:54 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Fwd: Strange/poor MM/Sched behaviour, 131ac8
In-Reply-To: <Pine.LNX.3.95.981210234954.21279A-100000@as200.spellcast.com>
Message-ID: <Pine.LNX.4.03.9812111049180.14401-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 10 Dec 1998, Benjamin C.R. LaHaise wrote:

> Sorry to post a downer, but I'm somewhat let down by 131 (I leapt right
> in at ac8).
> 
> Firstly, the scheduler still gives really jerky performance for
> interactive things when both CPU's are running CPU-intensive
> codes.  I'm talking here about what happens when you type at the
> command prompt etc. and get slow echoing of characters. (Rik - I
> haven't had time to patch in your scheduler mods yet...).

I believe my scheduler bigpatch would help somewhat here. I
will be getting an SMP machine (2xP120;) next week so expect
a proper SMP scheduler patch around christmas :)

> *** good healthy swapping here, 16mb/sec or so it appears, and vmstat is
>     still running once per second.  Context switches/sec ~= 1000.
>     BUT: Note that the cache size is climbing upwards at about 7-8megs per
>     second too - THIS is so weird -- swapping pages out to disk but caching
>     them in RAM ??  Or have I misunderstood?

You hit the nail on the head. We now cache te pages we swap out,
this gives us free page aging.

The differences in response time you saw can be explained by the
fact that the time between the swapping and the freeing of pages
can vary widely depending on the address the page has in memory.

And you'll have to admit that your swapout test was rather
artificial, only swapping _out_ without doing a swapin of
that memory -- in RL you might as well have freed it...

When a program both swaps out and in the newest kernels will
be an awful lot faster than what you're used to...

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
