Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA24911
	for <linux-mm@kvack.org>; Mon, 21 Dec 1998 14:39:21 -0500
Date: Mon, 21 Dec 1998 11:38:01 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <199812211859.SAA02961@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.981221113640.418C-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>



On Mon, 21 Dec 1998, Stephen C. Tweedie wrote:
>
> Yep, and although things did improve when I restored some of that
> aggressiveness (initial priority = 6 again), it was still mondo slow
> on 8MB.  I also restored the swapout loop (so that the foreground
> try_to_free_page() takes a swap cluster argument again, rather than
> always freeing just one page at a time);

Hmm.. It already does that. Maybe you didn't look at the "free_memory()"
macro?

>				 still no improvement (which
> actually surprised me --- I guess that kswapd is doing clustering for
> swapout well enough on its own).

You shouldn't be surprised, as I don't think you changed anything ;)

> Linus, would it help at all if I just sat down and recoded the VM I'm
> running now in a manner which makes the design obvious?  In other
> words, clearly separate out the foreground and background paths as you
> have done, with the "current != kswapd" test removed and the
> foreground-specific code in its own, identifiable code path, but
> preserving the actual algorithm?

Sure, send me patches.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
