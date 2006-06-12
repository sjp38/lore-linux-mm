Date: Mon, 12 Jun 2006 14:13:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060612211305.20862.34292.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com>
References: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 04/21] swap_prefetch: Convert nr_mapped to ZVC
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, Con Kolivas <kernel@kolivas.org>, Marcelo Tosatti <marcelo@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Chinner <dgc@sgi.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

This is separate on request by Andrew.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc6-cl/mm/swap_prefetch.c
===================================================================
--- linux-2.6.17-rc6-cl.orig/mm/swap_prefetch.c	2006-06-10 22:04:26.763047220 -0700
+++ linux-2.6.17-rc6-cl/mm/swap_prefetch.c	2006-06-12 11:29:47.664697453 -0700
@@ -394,7 +394,8 @@ static int prefetch_suitable(void)
 		 * even if the slab is being allocated on a remote node. This
 		 * would be expensive to fix and not of great significance.
 		 */
-		limit = ps.nr_mapped + ps.nr_slab + ps.nr_dirty +
+		limit = node_page_state(node, NR_MAPPED) +
+			ps.nr_slab + ps.nr_dirty +
 			ps.nr_unstable + total_swapcache_pages;
 		if (limit > ns->prefetch_watermark) {
 			node_clear(node, sp_stat.prefetch_nodes);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
