Date: Sun, 24 Sep 2000 20:59:48 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: __GFP_IO && shrink_[d|i]cache_memory()?
In-Reply-To: <Pine.LNX.4.10.10009241141410.789-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0009242058000.7843-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 24 Sep 2000, Linus Torvalds wrote:

> I think that shm_swap still needs it - it's doing things with
> rw_swap_page() that means that we cannot run it without GFP_IO.

yep - i only pushed the test inside, it's functionally equivalent - it
only vanished from refill_inactive(). It's basically now a detail of the
lowlevel swapping functions to honor __GFP_IO.

> So it makes sense to leave shm_swap() behaviour unchanged (ie do
> nothing if GFP_IO is not set), but move the GFP_IO test down into
> shm_swap() so that it will (a) match the other cases and (b) be easier
> to change the GFP_IO logic later on if/when we clean up shm.

yep.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
