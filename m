Date: Fri, 25 Feb 2000 00:30:59 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: [PATCH] kswapd performance fix
Message-ID: <Pine.LNX.4.10.10002250026040.1385-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi Alan,

here's a one-liner that makes kswapd a little bit faster
by not dirtying cache lines needlessly any more.

The patch should apply to any 2.2 or 2.3 kernel, but for
2.3 it'll have the interesting side effect of nullifying
the (minimal) page aging that's going on there.

Expect a patch for the newest 2.3 tomorrow :)
(if I'm not in a moving frenzy and packing my things
like I should be doing by now)

cheers,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.


--- linux/mm/vmscan.c.orig	Thu Feb 24 22:56:42 2000
+++ linux/mm/vmscan.c	Thu Feb 24 23:14:13 2000
@@ -55,7 +55,6 @@
 		 */
 		set_pte(page_table, pte_mkold(pte));
 		flush_tlb_page(vma, address);
-		set_bit(PG_referenced, &page_map->flags);
 		return 0;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
