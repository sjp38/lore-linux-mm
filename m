Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA13391
	for <linux-mm@kvack.org>; Wed, 9 Dec 1998 18:17:47 -0500
Date: Thu, 10 Dec 1998 00:15:50 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [PATCH] VM improvements for 2.1.131
In-Reply-To: <Pine.LNX.3.96.981209220124.25588B-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.981210001237.792A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Dec 1998, Rik van Riel wrote:

>This is because 'swapped' data is added to the cache. It also
>is because without it kswapd would not free memory in swap_out().
>Then, because it didn't free memory, it would continue to swap
>out more and more and still more with no effect (remember the
>removal of page aging?).

Nono, I reversed the vmscan changes on my tree. On my tree when swap_out
returns 1 it has really freed a page ;). I have many other differences...
I am going to do some other interesting benchmark right now to understand
if really my choices are the best as I think...

Andrea Arcangeli

PS to see other things grab arca-51.

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
