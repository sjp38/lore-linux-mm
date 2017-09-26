Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC4C6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 03:21:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x78so17104991pff.7
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 00:21:20 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id v26si5424031pgc.383.2017.09.26.00.21.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 00:21:19 -0700 (PDT)
From: changbin.du@intel.com
Subject: [PATCH] mm: update comments for struct page.mapping
Date: Tue, 26 Sep 2017 15:14:17 +0800
Message-Id: <1506410057-22316-1-git-send-email-changbin.du@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Changbin Du <changbin.du@intel.com>

From: Changbin Du <changbin.du@intel.com>

The struct page.mapping can NULL or points to one object of type
address_space, anon_vma or KSM private structure.

Signed-off-by: Changbin Du <changbin.du@intel.com>
---
 include/linux/mm_types.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 46f4ecf5..8dd6cb3 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -47,8 +47,8 @@ struct page {
 						 * inode address_space, or NULL.
 						 * If page mapped as anonymous
 						 * memory, low bit is set, and
-						 * it points to anon_vma object:
-						 * see PAGE_MAPPING_ANON below.
+						 * it points to anon_vma object
+						 * or KSM private structure.
 						 */
 		void *s_mem;			/* slab first object */
 		atomic_t compound_mapcount;	/* first tail page */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
