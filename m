Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA08432
	for <linux-mm@kvack.org>; Wed, 8 Jul 1998 15:21:23 -0400
Date: Wed, 8 Jul 1998 20:57:27 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807081345.OAA01509@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980708205506.15562A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Jul 1998, Stephen C. Tweedie wrote:
> On Tue, 7 Jul 1998 17:54:46 +0200 (CEST), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > There's a good compromize between balancing per-page
> > and per-process. We can simply declare the last X
> > (say 8) pages of a process holy unless that process
> > has slept for more than Y (say 5) seconds.
> 
> Yep --- this is per-process RSS management, and there is a _lot_ we
> can do once we start following this route.  I've been talking with
> some folk about it already, and this is something we definitely want
> to look into for 2.3.
> 
> The hard part is the self-tuning --- making sure that we don't give a

When my zone allocator is finished, it'll be a piece of
cake to implement lazy page reclamation.
With lazy reclamation, we simply place an upper limit
on the number of _active_ pages. A process that's really
thrashing away will simply be moving it's pages to/from
the inactive list.

And when memory pressure increases, other processes will
start taking pages away from the inactive pages collection
of our memory hog.

That looks quite OK to me...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
