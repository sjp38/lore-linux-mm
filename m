Date: Mon, 25 Sep 2000 19:03:46 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VMt
In-Reply-To: <Pine.LNX.4.10.10009250948170.1739-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0009251902250.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, Andi Kleen <ak@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Linus Torvalds wrote:

> Yes, I'm inclined to agree. Or at least not disagree. I'm more arguing
> that the order itself may not be the most interesting thing, and that
> I don't think the balancing has to take the order of the allocation
> into account - because it should be equivalent to just tell that it's
> a soft allocation (whether though the current !__GFP_HIGH or through a
> new __GFP_SOFT with slightly different logic).

yep, and there is another problem with pure order-based distinction: if i
do kmalloc(5k), and write the code on Alpha and expect it to never fail,
shouldnt i expect this to never fail on x86 as well? Along with the fork()
failure. __GFP_SOFT solves this all very nicely - the *allocator* decides
what allocation policy to follow. Great!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
