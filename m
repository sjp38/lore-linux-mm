Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA18402
	for <linux-mm@kvack.org>; Sun, 29 Nov 1998 18:51:43 -0500
Date: Mon, 30 Nov 1998 16:08:59 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
In-Reply-To: <199811301113.LAA02870@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981130160536.21650A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Nov 1998, Stephen C. Tweedie wrote:
> On 28 Nov 1998 01:31:00 -0600, ebiederm+eric@ccr.net (Eric W. Biederman)
> said:
> 
> > Why does it make sense when we want memory, to write every page
> > we can to swap before we free any memory?
> 
> What makes you think we do?

What makes you think think we don't? Apart from the buffer
and cache borrow percentages kswapd doesn't have any incentive
to switch back from swap_out() to shrink_mmap()...

> 2.1.130 tries to shrink cache until a shrink_mmap() pass fails. 
> Then it gives the swapper a chance, swapping a batch of pages and
> unlinking them from the ptes.  The pages so release still stay in
> the page cache at this point, btw, and will be picked up again from
> memory if they get referenced before the page finally gets
> discarded.  We then go back to shrink_mmap(), hopefully with a
                 ^^^^
The real question is _when_? Is it soon enough to keep the
system in a sane state?

> larger population of recyclable pages as a result of the swapout,
> and we start using that again. 
>
> We only run one batch of swapouts before returning to shrink_mmap.

It's just that this batch can grow so large that it isn't
any fun and kills performance. We _do_ want to fix this...

cheers,

Rik -- hoping that this post makes my point clear...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
