Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA15543
	for <linux-mm@kvack.org>; Thu, 21 May 1998 15:08:02 -0400
Received: from mirkwood.dummy.home (root@anx1p2.fys.ruu.nl [131.211.33.91])
	by max.fys.ruu.nl (8.8.7/8.8.7/hjm) with ESMTP id VAA12380
	for <linux-mm@kvack.org>; Thu, 21 May 1998 21:07:53 +0200 (MET DST)
Date: Thu, 21 May 1998 20:07:39 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Out of memory killer almost ready
Message-ID: <Pine.LNX.3.91.980521200258.18589A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I've now finished most of the Out of memory
killer, except for one thing.

I don't know what condition to test for for
when to start the procedure. We could wait
until kswapd truly fails, but wouldn't that
be waiting _too_ long. OTOH, if we don't,
we can kill a process when it isn't needed.

in kswapd:
	alive = 0;
	while (tries--) {
		cruft;
		if (try_to_free_page())
			alive = 1;	
	}
	if (!alive)
		out_of_memory_killer();

This has the disadvantage of:
- taking things too far
- kicking in when kswapd has just been very
  unlucky

OTOH, testing for free swap space won't help a bit
when we are killed by mlock(), pagetables and other
nonswappable things...

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.phys.uu.nl/~riel/          | <H.H.vanRiel@phys.uu.nl> |
+-------------------------------------------+--------------------------+
