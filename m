Date: Tue, 17 Sep 2002 22:22:15 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: VolanoMark Benchmark results for 2.5.26, 2.5.26 + rmap, 2.5.35,
 and  2.5.35 + mm1
In-Reply-To: <3D87AD85.74C1CC2D@digeo.com>
Message-ID: <Pine.LNX.4.44L.0209172219200.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Bill Hartner <hartner@austin.ibm.com>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 17 Sep 2002, Andrew Morton wrote:
> Bill Hartner wrote:
> >
> > I ran VolanoMark 2.1.2 under memory pressure to test rmap.
> >                              ---------------
>
> Interesting test.  We really haven't begun to think about these
> sorts of loads yet, alas.  Still futzing with lists, locks,
> IO scheduling, zone balancing, node balancing, etc.

Ummm ?  Performance under memory pressure was the whole reason I
started the rmap vm in the first place ;)

It's kind of strange to see all the balancing work being thrown
out the window now because it's "not interesting"...

> > 2.5.26 vs 2.5.26 + rmap patch
> > -----------------------------
> > It appears as though the page stealing decisions made when using the
> > 2.5.26 rmap patch may not be as good as the baseline for this workload.
> > There was more swap activity and idle time.
>
> Do you have similar results for 2.4 and 2.4-rmap?

If Bill is going to test this, I'd appreciate it if he could use
rmap14a (or newer, if I've released it by the time he gets around
to testing).

Btw, I'm about to backport the pte_chains from slabcache patch and
somebody from #kernelnewbies is looking at dmc's direct pte pointer
patch. I might integrate more 2.5 stuff in 2.4-rmap if people want
it.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
