Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA25677
	for <linux-mm@kvack.org>; Mon, 6 Jul 1998 11:32:09 -0400
Date: Mon, 6 Jul 1998 13:42:34 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807061038.LAA00803@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980706133936.5760C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Jul 1998, Stephen C. Tweedie wrote:
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > A few months ago someone (who?) posted a patch that modified
> > kswapd's internals to only unmap clean pages when told to.
> 
> > If I can find the patch, I'll integrate it and let kswapd
> > only swap clean pages when:
> 
> I'm not sure what that is supposed to achieve, and I'm not sure how well
> we expect such tinkering to work uniformly on 8MB and 512MB machines.
> Unmapping is not an issue with respect to cache sizes.

When we use this, we can finally 'enforce' the borrow_percent
stuff. Yes, I know the borrow_percent isn't really a good thing,
but we'll need the framework anyway when your balancing code
is implemented.

The 'only unmap clean pages' flag is a good way of implementing
this framework; maybe we want to combine it with a flag to
shrink_mmap() not to unmap swap cache pages...
Or maybe we want to do swap cache LRU reclamation when
free_memory_available(4) returns true.

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
