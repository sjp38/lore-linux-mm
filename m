Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id DAA11687
	for <linux-mm@kvack.org>; Thu, 9 Jul 1998 03:45:20 -0400
Date: Thu, 9 Jul 1998 09:43:20 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807082211.XAA14327@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980709094148.25891A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Jul 1998, Stephen C. Tweedie wrote:
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > When my zone allocator is finished, it'll be a piece of
> > cake to implement lazy page reclamation.
> 
> I've already got a working implementation.  The issue of lazy
> reclamation is pretty much independent of the allocator underneath; I
> don't see it being at all hard to run the lazy reclamation stuff on top
> of any form of zoned allocation.

The problem with the current allocator is that it stores
the pointers to available blocks in the blocks themselves.
This means we can't wait till the last moment with lazy
reclamation.

> is already present in 2.1 now.  The only thing missing is the
> maintenance of the LRU list of lazy pages for reuse.

That part will come for free with my zone allocator.

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
