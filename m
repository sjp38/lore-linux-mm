Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA24350
	for <linux-mm@kvack.org>; Mon, 21 Dec 1998 12:59:44 -0500
Date: Mon, 21 Dec 1998 09:58:10 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <199812211637.QAA02759@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.981221095438.6187B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>



On Mon, 21 Dec 1998, Stephen C. Tweedie wrote:
> 
> pre2 works OK on low memory for me but its performance on 64MB sucks
> here.  pre3 works fine on 64MB but its performance on 8MB sucks even
> more.

I'm testing it now - the problem is probably just due to my mixing up the
pre-2 and pre-3 patches, and pre-3 got the "timid" memory freeing
parameters even though the whole point of the pre-3 approach is that it
isn't needed any more.

>	  You simply CANNOT tell from looking at the code that it "will
> work well for everybody out there on every hardware".  

Agreed.

However, I very much believe that tweaking comes _after_ the basic
arhictecture is right. Before the basic architecture is correct, any
tweaking is useful only to (a) try to make do with a bad setup and (b) 
give hints as to what makes a difference, and what the basic architecture
_should_ be. 

As such, your "current != kswapd" tweak gave a whopping good hint about
what the architecture _should_ be. And we'll be zeroing in on something
that has both the performance and the architecture right. 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
