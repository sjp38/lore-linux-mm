Date: Sat, 6 May 2000 21:22:10 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [DATAPOINT] pre7-6 will not swap
In-Reply-To: <39149B81.B92C8741@sgi.com>
Message-ID: <Pine.LNX.4.21.0005062119500.1174-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: Benjamin Redelings I <bredelin@ucla.edu>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 May 2000, Rajagopal Ananthanarayanan wrote:

> What do you guys think?

I think you may want to take a look at
page_alloc.c::__alloc_pages(), where the kernel balances
between different zones...

- kswapd is woken up when zone->free_pages < zone->pages_low
- kswapd goes to sleep when it has freed enough pages in the
  current zone
- if another zone has a lower memory load, we'll free some
  "extra" pages in that other zone, up to zone->pages_high

This should provide enough balancing between zones...

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
