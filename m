Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA11536
	for <linux-mm@kvack.org>; Tue, 14 Apr 1998 20:17:08 -0400
Date: Wed, 15 Apr 1998 02:07:01 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: H.H.vanRiel@phys.uu.nl
Subject: [PATCH] high/low water mark -- correct
Message-ID: <Pine.LNX.3.91.980415020517.4560A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

after doing some arithmetic, I decided that the previous
patch was a little too much for small systems...
Please apply this one instead.

I will change the freepages struct to use these values
RSN...

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+

--- linux/mm/page_alloc.c.2196	Tue Apr 14 23:27:23 1998
+++ linux/mm/page_alloc.c	Wed Apr 15 02:04:39 1998
@@ -134,8 +134,9 @@
 	 * It may not be, due to fragmentation, but we
 	 * don't want to keep on forever trying to find
 	 * free unfragmented memory.
+	 * Added low/high water marks to avoid thrashing -- Rik.
 	 */
-	if (nr_free_pages > num_physpages >> 4)
+	if (nr_free_pages > (num_physpages >> 5) + (nr ? 0 : SWAP_CLUSTER_MAX))
 		return nr+1;
 
 	list = free_area + NR_MEM_LISTS;
