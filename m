Date: Fri, 9 Jun 2006 11:26:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: zoned VM stats: nr_slab is accurate, fix comment
Message-ID: <Pine.LNX.4.64.0606091122560.520@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Con Kolivas <kernel@kolivas.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

nr_slab is accurate with the zoned VM stats. Remove the comment
that states otherwise in swap_prefetch.c

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc6-mm1/mm/swap_prefetch.c
===================================================================
--- linux-2.6.17-rc6-mm1.orig/mm/swap_prefetch.c	2006-06-09 10:30:52.363683655 -0700
+++ linux-2.6.17-rc6-mm1/mm/swap_prefetch.c	2006-06-09 11:17:22.126406920 -0700
@@ -386,10 +386,6 @@ static int prefetch_suitable(void)
 		/*
 		 * >2/3 of the ram on this node is mapped, slab, swapcache or
 		 * dirty, we need to leave some free for pagecache.
-		 * Note that currently nr_slab is innacurate on numa because
-		 * nr_slab is incremented on the node doing the accounting
-		 * even if the slab is being allocated on a remote node. This
-		 * would be expensive to fix and not of great significance.
 		 */
 		limit = global_page_state(NR_MAPPED) +
 			global_page_state(NR_SLAB) +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
