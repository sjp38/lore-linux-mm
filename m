Date: Fri, 21 Apr 2000 18:00:10 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004212020410.17904-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0004211735510.11459-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, Ben LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Apr 2000, Andrea Arcangeli wrote:

> The swap-entry fixes cleared by the swap locking changes are here:
> 	
> ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/patches/v2.3/2.3.99-pre6-pre3/swap-entry-3

The patch looks "obviously correct", but it would be nice if
you could use the PageClearSwapCache and related macros for
changing the bitflags.

Things like
              new_page->flags &= ~(1UL << PG_swap_entry);
just make the code less readable than it has to be.

(and yes, loads of people already run away screaming when
they look at the memory management code, I really think we
should make maintainability a higher priority target for
the code)

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
