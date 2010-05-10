Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 964D76B024F
	for <linux-mm@kvack.org>; Mon, 10 May 2010 06:41:18 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 16/25] lmb: Move lmb_init() to the bottom of the file
Date: Mon, 10 May 2010 19:38:50 +1000
Message-Id: <1273484339-28911-17-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-16-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-7-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-8-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-9-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-10-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-11-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-12-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-13-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-14-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-15-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-16-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

It's a real PITA to have to search for it in the middle

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 lib/lmb.c |   54 +++++++++++++++++++++++++++---------------------------
 1 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/lib/lmb.c b/lib/lmb.c
index 9fd0145..141d4ab 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -107,33 +107,6 @@ static void lmb_coalesce_regions(struct lmb_type *type,
 	lmb_remove_region(type, r2);
 }
 
-void __init lmb_init(void)
-{
-	/* Hookup the initial arrays */
-	lmb.memory.regions	= lmb_memory_init_regions;
-	lmb.memory.max		= INIT_LMB_REGIONS;
-	lmb.reserved.regions	= lmb_reserved_init_regions;
-	lmb.reserved.max	= INIT_LMB_REGIONS;
-
-	/* Write a marker in the unused last array entry */
-	lmb.memory.regions[INIT_LMB_REGIONS].base = (phys_addr_t)RED_INACTIVE;
-	lmb.reserved.regions[INIT_LMB_REGIONS].base = (phys_addr_t)RED_INACTIVE;
-
-	/* Create a dummy zero size LMB which will get coalesced away later.
-	 * This simplifies the lmb_add() code below...
-	 */
-	lmb.memory.regions[0].base = 0;
-	lmb.memory.regions[0].size = 0;
-	lmb.memory.cnt = 1;
-
-	/* Ditto. */
-	lmb.reserved.regions[0].base = 0;
-	lmb.reserved.regions[0].size = 0;
-	lmb.reserved.cnt = 1;
-
-	lmb.current_limit = LMB_ALLOC_ANYWHERE;
-}
-
 void __init lmb_analyze(void)
 {
 	int i;
@@ -517,3 +490,30 @@ void __init lmb_set_current_limit(phys_addr_t limit)
 	lmb.current_limit = limit;
 }
 
+void __init lmb_init(void)
+{
+	/* Hookup the initial arrays */
+	lmb.memory.regions	= lmb_memory_init_regions;
+	lmb.memory.max		= INIT_LMB_REGIONS;
+	lmb.reserved.regions	= lmb_reserved_init_regions;
+	lmb.reserved.max	= INIT_LMB_REGIONS;
+
+	/* Write a marker in the unused last array entry */
+	lmb.memory.regions[INIT_LMB_REGIONS].base = (phys_addr_t)RED_INACTIVE;
+	lmb.reserved.regions[INIT_LMB_REGIONS].base = (phys_addr_t)RED_INACTIVE;
+
+	/* Create a dummy zero size LMB which will get coalesced away later.
+	 * This simplifies the lmb_add() code below...
+	 */
+	lmb.memory.regions[0].base = 0;
+	lmb.memory.regions[0].size = 0;
+	lmb.memory.cnt = 1;
+
+	/* Ditto. */
+	lmb.reserved.regions[0].base = 0;
+	lmb.reserved.regions[0].size = 0;
+	lmb.reserved.cnt = 1;
+
+	lmb.current_limit = LMB_ALLOC_ANYWHERE;
+}
+
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
