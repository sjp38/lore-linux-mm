Date: Sun, 27 May 2001 12:58:13 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] modified memory_pressure calculation
In-Reply-To: <3B10F351.6DDEC59@colorfullife.com>
Message-ID: <Pine.LNX.4.21.0105271256500.1907-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 27 May 2001, Manfred Spraul wrote:

> * if reclaim_page() finds a page that is Referenced, Dirty or Locked
>   then it must increase memory_pressure.

Why ?

> * I don't understand the purpose of the second ++ in alloc_pages().

It's broken and should be removed. Thanks for spotting
this one.

> What about the attached patch [vs. 2.4.5]? It's just an idea, untested.

Just remove the in_interrupt() check near PF_MEMALLOC, will you?

Adding that check makes it possible for a pingflood to deadlock
kswapd, as the network card can allocate the very last pages in
the system and kswapd needs those pages to free up memory.

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
