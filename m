Date: Fri, 19 May 2000 12:03:09 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.21.0005181848360.3896-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0005191150320.20142-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 18 May 2000, Andrea Arcangeli wrote:

> I still strongly think that the current zone strict mem
> balancing design is very broken (and I also think to be right
> since I believe to see the whole picture) but I don't think I
> can explain my arguments better and/or more extensively of how I
> just did in linux-mm some week ago.

The balancing as of pre9-2 works like this:
- LRU list per pgdat
- kswapd runs and makes sure every zone has > zone->pages_low
  free pages, after that it stops
- kswapd frees up to zone->pages_high pages, depending on what
  pages we encounter in the LRU queue, this will make sure that
  the zone with most least recently used pages will have more
  free pages
- __alloc_pages() allocates all pages up to zone->pages_low on
  every zone before waking up kswapd, this makes sure more pages
  from the least loaded zone will be used than from more loaded
  zones, this will make sure balancing between zones happens

I'm curious what would be so "very broken" about this?

AFAICS it does most of what the classzone patch would achieve,
at lower complexity and better readability.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
