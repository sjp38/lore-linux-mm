Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA32400
	for <linux-mm@kvack.org>; Tue, 22 Dec 1998 16:57:32 -0500
Date: Tue, 22 Dec 1998 13:56:05 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <Pine.LNX.4.03.9812222119540.397-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.981222135204.384D-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Andrea Arcangeli <andrea@e-mind.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>



On Tue, 22 Dec 1998, Rik van Riel wrote:
> > 
> > There's another one: if you never call shrink_mmap() in the swapper, the
> > swapper at least currently won't ever really know when it should finish.
> 
> Remember 2.1.89, when you solemnly swore off any kswapd solution
> that had anything to do with nr_freepages?

The problem is that we have to have _something_ to go by. I tried for the
longest time to use the memory queues, but eventually gave up. 

> I guess it's time to just let kswapd finish when there are enough
> pages that can be 'reapt' by shrink_mmap(). This is a somewhat less
> arbitrary way than what we have now, since those clean pages can be
> mapped back in any time.

If we'd have a count of "freeable pages", that would certainly work for
me. I only asked for _some_ way to know when it should finish. 

Btw, I just made a 2.1.132. I would have liked to get this issue put to
death, but it didn't look likely, and I had all the other patches pending
that I wanted out (the irda stuff etc), so 2.1.132 is reality, and I hope
we can work based on that.

Logically 2.1.132 should be reasonably close to Stephens patches, but as
the code actually looks very different it's hard for me to judge whether
it actually performs comparably. And a 8MB machine feels so sluggish to me
these days that I can't make any judgement at all from that. 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
