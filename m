Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 458606B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 09:38:52 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o85so4462986qkh.15
        for <linux-mm@kvack.org>; Wed, 17 May 2017 06:38:52 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id n10si2224342qtn.7.2017.05.17.06.38.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 06:38:51 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id y128so1642527qka.3
        for <linux-mm@kvack.org>; Wed, 17 May 2017 06:38:50 -0700 (PDT)
From: Michael DeGuzis <mdeguzis@gmail.com>
Subject: [PATCH] Correct spelling and grammar for notification text
Date: Wed, 17 May 2017 09:38:42 -0400
Message-Id: <20170517133842.5733-1-mdeguzis@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: trivial@kernel.org, professorkaos64 <mdeguzis@gmail.com>

From: professorkaos64 <mdeguzis@gmail.com>

This patch fixes up some grammar and spelling in the information
block for huge_memory.c.
---
 mm/huge_memory.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a84909cf20d3..af137fc0ca09 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -38,12 +38,12 @@
 #include "internal.h"
 
 /*
- * By default transparent hugepage support is disabled in order that avoid
- * to risk increase the memory footprint of applications without a guaranteed
- * benefit. When transparent hugepage support is enabled, is for all mappings,
- * and khugepaged scans all mappings.
+ * By default, transparent hugepage support is disabled in order to avoid
+ * risking an increased memory footprint for applications that are not 
+ * guaranteed to benefit from it. When transparent hugepage support is 
+ * enabled, it is for all mappings, and khugepaged scans all mappings.
  * Defrag is invoked by khugepaged hugepage allocations and by page faults
- * for all hugepage allocations.
+ * for all hugepage allocations. 
  */
 unsigned long transparent_hugepage_flags __read_mostly =
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
