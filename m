Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA25033
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 10:29:36 -0500
Date: Tue, 1 Dec 1998 16:28:13 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead v3 + kswapd fixes
In-Reply-To: <Pine.LNX.3.96.981201091401.969C-100000@dragon.bogus>
Message-ID: <Pine.LNX.3.96.981201162640.437A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Linux MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>, Linux-Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Dec 1998, Andrea Arcangeli wrote:
> On Tue, 1 Dec 1998, Rik van Riel wrote:
> 
> >--- ./mm/vmscan.c.orig	Thu Nov 26 11:26:50 1998
> >+++ ./mm/vmscan.c	Tue Dec  1 07:12:28 1998
> >@@ -431,6 +431,8 @@
> > 	kmem_cache_reap(gfp_mask);
> > 
> > 	if (buffer_over_borrow() || pgcache_over_borrow())
> >+		state = 0;		
> 
> This _my_ patch should be enough. Did you tried it without the other
> stuff?

Yes, I tried the other stuff but something broke without
the little piece I added. All my piece added to vmscan.c
does is make sure that we actually free memory when we
have done some swap_out()s.

Otherwise kswapd won't stop swapping when things 'go well'.

cheers,

Rik -- now completely used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
