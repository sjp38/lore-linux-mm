Date: Mon, 25 Sep 2000 14:10:07 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: the new VMt
In-Reply-To: <20000925191703.G27677@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251407020.20061-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Andi Kleen <ak@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:
> On Mon, Sep 25, 2000 at 07:03:46PM +0200, Ingo Molnar wrote:
> > [..] __GFP_SOFT solves this all very nicely [..]
> 
> s/very nicely/throwing away lots of useful cache for no one good reason/

Not really. We could fix this by making the page freeing
functions smarter and only free the pages we need.

I just don't know if this is worth it for 0.5% of the 
allocations (and further more, since we allocate the
1-page allocations directly from the cache when we're
low on free memory, fragmentation isn't as bad as it
used to be with the old VM).

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
