Date: Sun, 5 Sep 2004 10:24:57 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC][PATCH 0/3] beat kswapd with the proverbial clue-bat
In-Reply-To: <413AE6E7.5070103@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0409051021290.2331@ppc970.osdl.org>
References: <413AA7B2.4000907@yahoo.com.au> <20040904230210.03fe3c11.davem@davemloft.net>
 <413AAF49.5070600@yahoo.com.au> <413AE6E7.5070103@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "David S. Miller" <davem@davemloft.net>, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Sun, 5 Sep 2004, Nick Piggin wrote:
> 
> Hmm, and the crowning argument for not stopping at order 3 is that if we
> never use higher order allocations, nothing will care about their watermarks
> anyway. I think I had myself confused when that question in the first place.
> 
> So yeah, stopping at a fixed number isn't required, and as you say it keeps
> things general and special cases minimal.

Hey, please refute my "you need 20% free" to get even to order-3 for most
cases first.

It's probably acceptable to have a _very_ backgrounded job that does
freeing if order-3 isn't available, but it had better be pretty
slow-moving, I suspect. On the order of "It's probably ok to try to aim
for up to 25% free 'overnight' if the machine is idle" but it's almost
certainly not ok to aggressively push things out to that degree..

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
