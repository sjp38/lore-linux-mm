Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 50E14600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:19:06 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [27/31] HWPOISON: Use correct name for MADV_HWPOISON in documentation
Message-Id: <20091208211643.8FB73B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:43 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 Documentation/vm/hwpoison.txt |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux/Documentation/vm/hwpoison.txt
===================================================================
--- linux.orig/Documentation/vm/hwpoison.txt
+++ linux/Documentation/vm/hwpoison.txt
@@ -92,7 +92,7 @@ PR_MCE_KILL_GET
 
 Testing:
 
-madvise(MADV_POISON, ....)
+madvise(MADV_HWPOISON, ....)
 	(as root)
 	Poison a page in the process for testing
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
