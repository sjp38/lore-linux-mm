Date: Wed, 3 May 2000 07:37:21 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
In-Reply-To: <Pine.LNX.4.21.0005030228300.3498-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0005030736590.10610-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 3 May 2000, Andrea Arcangeli wrote:

> So what I propose is to set the entry bit in the swapin path only if we
> take over the swap cache, and to clear it in do_wp_page during COW and in
> free_page_and_swap_cache unconditionally (we know if it's set the page was
> not shared). We should also set it while taking over the swap cache in the
> cow after removing the page from the swap cache (in the case the page
> isn't shared).

> Note that dirty swap cache during COW have the same problem to choose if
> the swap entry should be inherit by the old page or by the new page (so
> it's not going to be a solution for that). My conclusion is that dropping
> the persistence on the swap during cow looks rasonable action.

Sounds like a good idea to me.

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
