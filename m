Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA23132
	for <linux-mm@kvack.org>; Mon, 21 Dec 1998 09:09:49 -0500
Date: Mon, 21 Dec 1998 15:08:35 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <199812211339.NAA02125@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981221150612.546A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Dec 1998, Stephen C. Tweedie wrote:

>in every case I have tried.  132-pre3 seems OK on a larger memory
>machine, but there's no way I'll be running it on my low-memory test
>boxes.

Could you try to apply my patch I sent to you too some minutes ago? It
seems to perform well at least on 32Mbyte. The point is that setting the
prio = 4 in try_to_free_pages() avoid that processes will stuck in the
SYNC IO. 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
