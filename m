Date: Tue, 9 May 2000 10:53:44 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] active/inactive lists
In-Reply-To: <m12p9Ls-000OWuC@amadeus.home.nl>
Message-ID: <Pine.LNX.4.21.0005091048300.25637-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@fenrus.demon.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 May 2000, Arjan van de Ven wrote:

> Where the last goto enters the loop again. But what stops others
> (including other CPUs in the same funcion) from puting the new
> page_lru on another queue or mess with it in an other way? The
> "goto next_page" probably should be changed into something that
> starts at a point that is guaranteed to be in the correct queue.

Indeed. I've fixed this (and now I'm walking into the next bug,
but I'm no longer sure if it has anything to do with the MM code).

NMI Watchdog detected LOCKUP on CPU1

>>EIP; c01fcaac <stext_lock+77c/89f0>   <=====
Trace; c0205bbd <call_apic_timer_interrupt+5/18>      (__wake_up??)
Trace; c0125ad5 <refill_inactive+139/1e4>
Trace; c012e0ee <do_try_to_free_pages+82/e8>
Trace; c012e221 <kswapd+cd/19c>
Trace; c0105000 <empty_bad_page+0/1000>
Trace; c0107533 <kernel_thread+23/30>
Code;  c01fcaac <stext_lock+77c/89f0>

cheers,

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
