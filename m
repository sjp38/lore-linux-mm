Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B5EC66B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 15:19:25 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 36so7910111qkz.10
        for <linux-mm@kvack.org>; Wed, 17 May 2017 12:19:25 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id u63si3029821qkc.158.2017.05.17.12.19.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 12:19:24 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id y128so3011370qka.3
        for <linux-mm@kvack.org>; Wed, 17 May 2017 12:19:24 -0700 (PDT)
From: Michael DeGuzis <mdeguzis@gmail.com>
Subject: [PATCH v2] PATCH [PATCH 001] memory management: spelling and grammar
Date: Wed, 17 May 2017 15:19:21 -0400
Message-Id: <20170517191921.14415-1-mdeguzis@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: trivial@kernel.org, Michael DeGuzis <mdeguzis@gmail.com>

This patch fixes up some grammar and spelling in the
information block for huge_memory.c.

* Fix grammary/spelling in mm/huge_memory.c

Signed-off-by: Michael DeGuzis <mdeguzis@gmail.com>
---
 mm/huge_memory.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a84909cf20d3..b75b8f08eb86 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -38,10 +38,10 @@
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
  * for all hugepage allocations.
  */
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
