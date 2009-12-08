Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E917E600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:45 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [26/31] HWPOISON: mention HWPoison in Kconfig entry
Message-Id: <20091208211642.8CEA1B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:42 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux/mm/Kconfig
===================================================================
--- linux.orig/mm/Kconfig
+++ linux/mm/Kconfig
@@ -257,7 +257,7 @@ config MEMORY_FAILURE
 	  special hardware support and typically ECC memory.
 
 config HWPOISON_INJECT
-	tristate "Poison pages injector"
+	tristate "HWPoison pages injector"
 	depends on MEMORY_FAILURE && DEBUG_KERNEL
 
 config NOMMU_INITIAL_TRIM_EXCESS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
