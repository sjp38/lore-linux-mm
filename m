Date: Mon, 12 Jun 2006 14:13:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060612211341.20862.95937.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com>
References: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 11/21] swap_prefetch: Conversion of nr_slab to ZVC
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, Con Kolivas <kernel@kolivas.org>, Marcelo Tosatti <marcelo@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Chinner <dgc@sgi.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

This removes a potential problem for swap_prefetch. Use NR_SLAB
and remove the comment stating the problem.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc6-cl/mm/swap_prefetch.c
===================================================================
--- linux-2.6.17-rc6-cl.orig/mm/swap_prefetch.c	2006-06-12 11:30:59.995187077 -0700
+++ linux-2.6.17-rc6-cl/mm/swap_prefetch.c	2006-06-12 11:55:06.458392224 -0700
@@ -389,14 +389,11 @@ static int prefetch_suitable(void)
 		/*
 		 * >2/3 of the ram on this node is mapped, slab, swapcache or
 		 * dirty, we need to leave some free for pagecache.
-		 * Note that currently nr_slab is innacurate on numa because
-		 * nr_slab is incremented on the node doing the accounting
-		 * even if the slab is being allocated on a remote node. This
-		 * would be expensive to fix and not of great significance.
 		 */
 		limit = node_page_state(node, NR_MAPPED) +
 			node_page_state(node, NR_ANON) +
-			ps.nr_slab + ps.nr_dirty +
+			node_page_state(node, NR_SLAB) +
+			ps.nr_dirty +
 			ps.nr_unstable + total_swapcache_pages;
 		if (limit > ns->prefetch_watermark) {
 			node_clear(node, sp_stat.prefetch_nodes);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
