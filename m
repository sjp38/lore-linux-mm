Date: Fri, 29 Sep 2000 12:40:14 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <20000929165511.C32079@athlon.random>
Message-ID: <Pine.LNX.4.21.0009291237161.23266-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Rohland <cr@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Sep 2000, Andrea Arcangeli wrote:
> On Fri, Sep 29, 2000 at 11:39:18AM -0300, Rik van Riel wrote:
> > OK, good to see that we agree on the fact that we
> > should age and swapout all pages equally agressively.
> 
> Actually I think we should start looking at the mapped stuff
> _only_ when the I/O cache aging is relevant. If the I/O cache
> aging isn't relevant there's no point to look at the mapped
> stuff since there's cache pollution going on.

> If the cache is re-used (so if it's useful) that's completly
> different issue and in that case unmapping potentially unused
> stuff is the right thing to do of course.

This is why I want to do:

1) equal aging of all pages in the system
2) page aging to have properties of both LRU and LFU
3) drop-behind to cope with streaming IO in a good way

and maybe:
4) move unmapped pages to the inactive_clean list for
   immediate reclaiming but put pages which are/were
   mapped on the inactive_dirty list so we keep it a
   little bit longer


The only way to reliably know if the cache is re-used a
lot is by making sure we do the page aging for unmapped
and mapped pages the same. If we don't do that, we won't
be able to make a sensible comparison between the activity
of pages in different places.

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
