Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id DAA23134
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 03:16:34 -0500
Date: Tue, 1 Dec 1998 09:15:22 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [PATCH] swapin readahead v3 + kswapd fixes
In-Reply-To: <Pine.LNX.3.96.981201075322.509A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.981201091401.969C-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>, Linux-Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Dec 1998, Rik van Riel wrote:

>--- ./mm/vmscan.c.orig	Thu Nov 26 11:26:50 1998
>+++ ./mm/vmscan.c	Tue Dec  1 07:12:28 1998
>@@ -431,6 +431,8 @@
> 	kmem_cache_reap(gfp_mask);
> 
> 	if (buffer_over_borrow() || pgcache_over_borrow())
>+		state = 0;		

This _my_ patch should be enough. Did you tried it without the other
stuff?

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
