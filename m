Date: Tue, 15 Aug 2000 23:46:22 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: filemap.c SMP bug in 2.4.0-test*
In-Reply-To: <Pine.LNX.4.10.10008151938240.3600-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0008152344500.3400-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Aug 2000, Linus Torvalds wrote:
> On Tue, 15 Aug 2000, Rik van Riel wrote:
> > 
> > The debugging check (in mm/swap.c::lru_cache_add(), line 232)
> > checks if the page which is to be added to the page lists is
> > already on one of the lists. In case it is, a nice backtrace
> > follows...
> 
> Why do you think your "PageActive()"/"PageInactiveDirty()"/
> "PageInactiveClean()" tests are right?
> 
> I don't see any reason to assume that you just don't clear the flags
> correctly.
> 
> In fact, if this bug really existed in the standard kernel, you'd see
> machines locking up left and right. Adding a page to a the LRU list  when
> it already is on the LRU list would cause immediate and severe list
> corruption. It wouldn't just go silently in the night, it would _scream_. 
> 
> I would suggest that you add something like DEBUG_ADD_PAGE to
> __free_pages_ok(), and see if somebody frees the page without
> clearing the flags. Sounds like a bug in your code.

This test is in _all_ places where pages are added or
removed from the list and in __free_pages_ok().

The only place where I'm hitting the bug is in
lru_cache_add.

OTOH, I wouldn't mind it if you were to take a look
at my code and potted the bug ;))

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
