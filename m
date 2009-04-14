Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 297595F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 12:44:42 -0400 (EDT)
Date: Tue, 14 Apr 2009 18:45:20 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/5] slqb: fix compilation warning
Message-ID: <20090414164520.GB14873@wotan.suse.de>
References: <20090414164439.GA14873@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090414164439.GA14873@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


slqb: fix compilation warning

gather_stats is not used if CONFIG_SLQB_SYSFS is not selected. Make
it conditional and avoid the warning.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/slqb.c
===================================================================
--- linux-2.6.orig/mm/slqb.c	2009-04-01 03:11:05.000000000 +1100
+++ linux-2.6/mm/slqb.c	2009-04-01 03:11:25.000000000 +1100
@@ -3121,6 +3121,7 @@ static void gather_stats_locked(struct k
 	stats->nr_objects = stats->nr_slabs * s->objects;
 }
 
+#ifdef CONFIG_SLQB_SYSFS
 static void gather_stats(struct kmem_cache *s, struct stats_gather *stats)
 {
 	down_read(&slqb_lock); /* hold off hotplug */
@@ -3128,6 +3129,7 @@ static void gather_stats(struct kmem_cac
 	up_read(&slqb_lock);
 }
 #endif
+#endif
 
 /*
  * The /proc/slabinfo ABI

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
