Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA06246
	for <linux-mm@kvack.org>; Fri, 27 Nov 1998 04:24:55 -0500
Date: Fri, 27 Nov 1998 06:27:04 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: borrow percentages & new VM scheme
Message-ID: <Pine.LNX.3.96.981127062128.356A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I've found that the rediculous amount of swapping associated
with 2.1.130-pre3 goes away if you reduce the borrow percentages
for both buffer and page cache to 10 percent...

We probably want 15% for the borrow percentage on small (<32M)
boxes, but nothing more either.

Lowering the borrow percentage gives kswapd the 'need' to prune
the cache once in a while, even when it is still easy to unmap
something in swap_out().

Because kswapd usually only switches when there is a failure
for either swap_out() or shrink_mmap() it can continue with
swap_out() (since there still is not enough memory free) doing
1000+ swapouts a second for a 7 second period (on my box) which
is just a bit too much.

We need some sort of mechanism to make kswapd switch tactics
more often, or else system stability and performance may
suffer.

regards,

Rik -- now completely used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
