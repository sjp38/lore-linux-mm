Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iBGM0MSn013881
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 17:00:22 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBGM0LqZ251558
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 17:00:21 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBGM0LLG029447
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 17:00:21 -0500
Subject: [patch] remove pfn_to_pgdat() on x86
From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 16 Dec 2004 14:00:19 -0800
Message-Id: <E1Cf3fY-0002qD-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: mbligh@aracnet.com, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This function is unused on i386.

Does anybody see a reason not to get rid of it?

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 apw2-dave/include/asm-i386/mmzone.h |    6 ------
 1 files changed, 6 deletions(-)

diff -puN include/asm-i386/mmzone.h~001-remove-pfn_to_pgdat include/asm-i386/mmzone.h
--- apw2/include/asm-i386/mmzone.h~001-remove-pfn_to_pgdat	2004-12-16 13:56:36.000000000 -0800
+++ apw2-dave/include/asm-i386/mmzone.h	2004-12-16 13:56:36.000000000 -0800
@@ -48,12 +48,6 @@ static inline int pfn_to_nid(unsigned lo
 #endif
 }
 
-static inline struct pglist_data *pfn_to_pgdat(unsigned long pfn)
-{
-	return(NODE_DATA(pfn_to_nid(pfn)));
-}
-
-
 /*
  * Following are macros that are specific to this numa platform.
  */
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
