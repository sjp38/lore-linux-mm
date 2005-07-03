Date: Sun, 3 Jul 2005 18:00:23 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [PATCH] remove completly bogus comment inside __alloc_pages() try_to_free_pages handling
Message-ID: <20050703210023.GC21166@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Remove completly bogus comment from did_some_progress != 0 handling (that
same comment is a few lines below on did_some_progress = 0 case, where it 
belongs).

--- linux-2.6.11/mm/page_alloc.c.orig	2005-07-03 11:55:53.000000000 -0300
+++ linux-2.6.11/mm/page_alloc.c	2005-07-03 11:56:24.000000000 -0300
@@ -786,12 +786,6 @@
 	cond_resched();
 
 	if (likely(did_some_progress)) {
-		/*
-		 * Go through the zonelist yet one more time, keep
-		 * very high watermark here, this is only to catch
-		 * a parallel oom killing, we must fail if we're still
-		 * under heavy pressure.
-		 */
 		for (i = 0; (z = zones[i]) != NULL; i++) {
 			if (!zone_watermark_ok(z, order, z->pages_min,
 					       classzone_idx, can_try_harder,
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
