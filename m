Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 619F8600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:57 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [29/31] HWPOISON: Undefine short-hand macros after use to avoid namespace conflict
Message-Id: <20091208211645.95423B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:45 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/memory-failure.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -747,6 +747,19 @@ static struct page_state {
 	{ 0,		0,		"unknown page state",	me_unknown },
 };
 
+#undef dirty
+#undef sc
+#undef unevict
+#undef mlock
+#undef writeback
+#undef lru
+#undef swapbacked
+#undef head
+#undef tail
+#undef compound
+#undef slab
+#undef reserved
+
 static void action_result(unsigned long pfn, char *msg, int result)
 {
 	struct page *page = pfn_to_page(pfn);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
