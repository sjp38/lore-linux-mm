Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D89B2600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:49 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [25/31] HWPOISON: Don't do early filtering if filter is disabled
Message-Id: <20091208211641.8A2FBB151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:41 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/hwpoison-inject.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux/mm/hwpoison-inject.c
===================================================================
--- linux.orig/mm/hwpoison-inject.c
+++ linux/mm/hwpoison-inject.c
@@ -18,6 +18,8 @@ static int hwpoison_inject(void *data, u
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
+	if (!hwpoison_filter_enable)
+		goto inject;
 	if (!pfn_valid(pfn))
 		return -ENXIO;
 
@@ -48,6 +50,7 @@ static int hwpoison_inject(void *data, u
 	if (err)
 		return 0;
 
+inject:
 	printk(KERN_INFO "Injecting memory failure at pfn %lx\n", pfn);
 	return __memory_failure(pfn, 18, MF_COUNT_INCREASED);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
