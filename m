Date: Mon, 16 Jul 2001 16:00:16 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Separate global/perzone inactive/free shortage 
In-Reply-To: <20010716155126.37887.qmail@web14306.mail.yahoo.com>
Message-ID: <Pine.LNX.4.33L.0107161553090.5738-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, Dirk Wetter <dirkw@rentec.com>, Mike Galbraith <mikeg@wen-online.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Jul 2001, Kanoj Sarcar wrote:

> Just a quick note. A per-zone page reclamation
> method like this was what I had advocated and sent
> patches to Linus for in the 2.3.43 time frame or so.
> I think later performance work ripped out that work.

Yes, the system ended up swapping as soon as the first zone
was filled up and after that would fill up the other zones;
the way the system stabilised was cycling through the pages
of one zone and leaving the lower zones alone.

This reduced the amount of available VM of a 1GB system
to 128MB, which is somewhat suboptimal ;)

What we learned from that is that we need to have some
way to auto-balance the reclaiming, keeping the objective
of evicting the least used page from RAM in mind.

> I guess the problem is that a lot of the different
> page reclamation schemes first of all do not know
> how to reclaim pages for a specific zone,

> try_to_swap_out is a good example, which can be solved
> by rmaps.

Indeed. Most of the time things go right, but the current
system cannot cope at all when things go wrong. I think we
really want things like rmaps and more sturdy reclaiming
mechanisms to cope with these worst cases (and also to make
the common case easier to get right).

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
