Received: from penguin.e-mind.com ([195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA25373
	for <linux-mm@kvack.org>; Sat, 11 Jul 1998 11:12:52 -0400
Date: Sat, 11 Jul 1998 17:11:37 +0200 (CEST)
From: Andrea Arcangeli <arcangeli@mbox.queen.it>
Subject: Re: [PATCH] stricter pagecache pruning
In-Reply-To: <Pine.LNX.3.96.980711092706.5292B-200000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.980711170623.4602A-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 11 Jul 1998, Rik van Riel wrote:

>Hi,
>
>I hope this patch will alleviate some of Andrea's
>problems with the page cache growing out of bounds.

Yes it seems really to help. Anyway I think that we could do something of
more clever. Now it happens more rarely that kswapd has to swapout things.
But when this happen the machine stall as usual.

For example if I run `free` a lot of times while cp file /dev/zero is
running, `free` stall only when free' s output will show that the swap is
been increased of a bit (and that some kbyte really don' t help in
function of increased free memory, they only cause a stall sometimes). 

The patch helps though, thanks. No other problems so far.

Andrea[s] Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
