Date: Tue, 21 Aug 2001 19:35:23 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH][RFC] using a memory_clock_interval
In-Reply-To: <200108212108.f7LL8Za08285@maila.telia.com>
Message-ID: <Pine.LNX.4.33L.0108211932280.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Aug 2001, Roger Larsson wrote:

> > That makes the inactive target not dynamic anymore.
>
> It is still dymanic due the fact that kswapd will be run not depending on a
> wall clock, but on problematic allocations done.
> (i.e. inactive_target looses its meaning for the VM since it measures
> pages/second but second is no more a base for kswapd runs... both mean
> - I want to have this amount of reclaimable pages until the next
> kswapd run...)

But we still want the inactive list to be "1 second" large,
both to give us more than enough time to do the pageout IO
and in order to give programs a good chance to use the pages
again.

regards,

Rik
--
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
