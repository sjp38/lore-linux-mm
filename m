Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA04216
	for <linux-mm@kvack.org>; Wed, 17 Jun 1998 00:45:58 -0400
Received: from mirkwood.dummy.home (root@anx1p6.phys.uu.nl [131.211.33.95])
	by max.phys.uu.nl (8.8.7/8.8.7/hjm) with ESMTP id GAA07347
	for <linux-mm@kvack.org>; Wed, 17 Jun 1998 06:45:54 +0200 (MET DST)
Received: from localhost (riel@localhost)
	by mirkwood.dummy.home (8.9.0/8.9.0) with SMTP id AAA06878
	for <linux-mm@kvack.org>; Wed, 17 Jun 1998 00:10:08 +0200
Date: Wed, 17 Jun 1998 00:10:07 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: PTE chaining, kswapd and swapin readahead
Message-ID: <Pine.LNX.3.96.980617000413.6859C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

In the PTE chaining discussion/patches a while ago, I saw
that kswapd was changed in a way that it scanned memory
in physical order instead of walking the pagetables.

This has the advantage of deallocating memory in physically
adjecant chunks, which will be nice while we still have the
primitive buddy allocator we're using now.

However, it will be a major performance bottleneck when we
get around to implementing the zone allocator and swapin
readahead. This is because we don't need physical deallocation
with the zone allocatore and because swapin readahead is just
an awful lot faster when the pages are contiguous in swap.

I write this to let the PTE people (Stephen and Ben) know
that they probably shouldn't remove the pagetable walking
routines from kswapd...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
