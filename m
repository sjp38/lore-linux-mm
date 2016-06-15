Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 85EF56B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 05:34:45 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id b13so21948234pat.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 02:34:45 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id e28si36049804pfk.242.2016.06.15.02.34.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 02:34:44 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id fg1so1199165pad.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 02:34:44 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v2] mm/page_alloc: remove unnecessary order check in __alloc_pages_direct_compact
Date: Wed, 15 Jun 2016 17:34:18 +0800
Message-Id: <1465983258-3726-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mhocko@suse.com, mina86@mina86.com, minchan@kernel.org, khandual@linux.vnet.ibm.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

In the callee try_to_compact_pages(), the (order == 0) is checked,
so remove check in __alloc_pages_direct_compact.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
v2:
  remove the check in __alloc_pages_direct_compact - Anshuman Khandual
---
 mm/page_alloc.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b9ea618..2f5a82a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3173,9 +3173,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct page *page;
 	int contended_compaction;
 
-	if (!order)
-		return NULL;
-
 	current->flags |= PF_MEMALLOC;
 	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
 						mode, &contended_compaction);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
