Date: Mon, 25 Sep 2000 13:41:02 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: the new VMt
In-Reply-To: <Pine.LNX.4.10.10009250931570.1739-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0009251338340.14614-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Linus Torvalds wrote:
> On Mon, 25 Sep 2000, Andrea Arcangeli wrote:
> > 
> > But I'd much prefer to pass not only the classzone from allocator
> > to memory balancing, but _also_ the order of the allocation,
> > and then shrink_mmap will know it doesn't worth to free anything 
> > that isn't contigous on the order of the allocation that we need.
> 
> I suspect that the proper way to do this is to just make another gfp_flag,
> which is basically another hint to the mm layer that we're doing a multi-
> page allocation and that the MM layer should not try forever to handle it.
> 
> In fact, that's independent of whether it is a multi-page
> allocation or not. It might be something like __GFP_SOFT - you
> could use it with single pages too.
> 
> Thinking about it, we do have it already. It's called
> !__GFP_HIGH, and it used by all the GFP_USER allocations.

Hmm, I think these two are orthagonal.

__GFP_HIGH means that we are allowed to eat deeper into
the free list (maybe needed to avoid a deadlock freeing
pages)

__GFP_SOFT would mean "don't bother waiting for free pages",
which is something very different...

(I wouldn't want a user process to get killed simply because
kswapd is waiting for IO to finish on a swapout, in that case
we really do want to sleep for a while)

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
