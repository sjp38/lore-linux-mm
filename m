Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA26509
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 14:00:49 -0500
Date: Tue, 1 Dec 1998 19:42:46 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: 2.1.130 mem usage. (fwd)
In-Reply-To: <Pine.LNX.3.96.981201183922.243B-100000@dragon.bogus>
Message-ID: <Pine.LNX.3.96.981201193815.4046C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Dec 1998, Andrea Arcangeli wrote:

> -		free_page_and_swap_cache(page);
> +		free_page(page);
>  
> Doing this we are not swapping out really I think, because the page
> now is also on the hd, but it' s still in memory and so
> shrink_mmap() will have the double of the work to do. 

This is the whole idea. Having shrink_mmap() do the freeing
gives us something like page aging, but at a much much lower
cost.

> I' ll try to reverse these patches right now in my own tree.

The only thing I'll tell you is that performance will be
far worse. The rest you can probably figure out yourself:)

Btw, the 'unused' entry in the page struct is there so we
can do math on page_structs without having to divide by
strange numbers (an order of magnitude slower on most
CPUs).

regards,

Rik -- now completely used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
