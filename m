Date: Sun, 24 Sep 2000 11:46:43 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: __GFP_IO && shrink_[d|i]cache_memory()?
In-Reply-To: <Pine.LNX.4.10.10009241138080.783-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10009241141410.789-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

[ Sorry to follow up on myself.. ]

On Sun, 24 Sep 2000, Linus Torvalds wrote:
> 
> Send me the tested patch (and I'd suggest moving the shm_swap() test into
> shm_swap() too, so that refill_inactive() gets cleaned up a bit).

I think that shm_swap still needs it - it's doing things with
rw_swap_page() that means that we cannot run it without GFP_IO.

HOWEVER, I suspect that in the long run we should move to using the page
cache better by the shm routines, and that might mean that eventually we
can do it even without GFP_IO (and instead let the generic VM routines
handle the actual IO on the swap cache). 

So it makes sense to leave shm_swap() behaviour unchanged (ie do nothing
if GFP_IO is not set), but move the GFP_IO test down into shm_swap() so
that it will (a) match the other cases and (b) be easier to change the
GFP_IO logic later on if/when we clean up shm.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
