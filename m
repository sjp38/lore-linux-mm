Date: Mon, 25 Sep 2000 09:49:46 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: the new VMt
In-Reply-To: <Pine.LNX.4.21.0009251338340.14614-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10009250948170.1739-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 25 Sep 2000, Rik van Riel wrote:
> > 
> > Thinking about it, we do have it already. It's called
> > !__GFP_HIGH, and it used by all the GFP_USER allocations.
> 
> Hmm, I think these two are orthagonal.
> 
> __GFP_HIGH means that we are allowed to eat deeper into
> the free list (maybe needed to avoid a deadlock freeing
> pages)
> 
> __GFP_SOFT would mean "don't bother waiting for free pages",
> which is something very different...

Yes, I'm inclined to agree. Or at least not disagree. I'm more arguing
that the order itself may not be the most interesting thing, and that I
don't think the balancing has to take the order of the allocation into
account - because it should be equivalent to just tell that it's a soft
allocation (whether though the current !__GFP_HIGH or through a new
__GFP_SOFT with slightly different logic).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
