Date: Mon, 25 Sep 2000 16:26:17 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <20000925213242.A30832@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251622500.4997-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:
> On Mon, Sep 25, 2000 at 07:06:57PM +0100, Stephen C. Tweedie wrote:
> > Good.  One of the problems we always had in the past, though, was that
> > getting the relative aging of cache vs. vmas was easy if you had a
> > small set of test loads, but it was really, really hard to find a
> > balance that didn't show pathological behaviour in the worst cases.
> 
> Yep, that's not trivial.

It is. Just do physical-page based aging (so you age all the
pages in the system the same) and the problem is solved.

> > > I may be overlooking something but where do you notice when a page
> > > gets unmapped from the last mapping and put it back into a place
> > > that can be reached from shrink_mmap (or whatever the cache recycler is)?
> > 
> > It doesn't --- that is part of the design.  The vm scanner propagates
> 
> And that's the inferior part of the design IMHO.

Indeed, but physical page based aging is a definate
2.5 thing ... ;(

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
