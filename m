Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA24498
	for <linux-mm@kvack.org>; Sat, 11 Jul 1998 07:39:42 -0400
Date: Sat, 11 Jul 1998 13:18:35 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980708231741.352A-100000@dragon.bogus>
Message-ID: <Pine.LNX.3.96.980711131614.6185A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <arcangeli@mbox.queen.it>
Cc: Linux MM <linux-mm@kvack.org>, Stephen Tweedie <sct@dcs.ed.ac.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Jul 1998, Andrea Arcangeli wrote:
> On Wed, 8 Jul 1998, Stephen C. Tweedie wrote:
> 
> >I'm unconvinced.  It's pretty clear that the underlying problem is that
> >the cache is far too agressive when you are copying large amounts of
> >data around.  The fact that interactive performance is bad suggests not
> >that the swapping algorithm is making bad decisions, but that it is
> >being forced to work with far too little physical memory due to the
> >cache size.

This morning I have posted a patch to Linux MM which can
drastically improve this situation.

For the low-mem linux-kernel users, you can get the patch
from my homepage too.

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
