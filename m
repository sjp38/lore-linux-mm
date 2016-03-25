Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE7E6B007E
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 06:05:49 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id 4so79935827pfd.0
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 03:05:49 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id li15si780024pab.113.2016.03.25.03.05.48
        for <linux-mm@kvack.org>;
        Fri, 25 Mar 2016 03:05:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: fix typo in khugepaged_scan_pmd()
Date: Fri, 25 Mar 2016 13:05:43 +0300
Message-Id: <1458900343-77088-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

!PageLRU should lead to SCAN_PAGE_LRU, not SCAN_SCAN_ABORT result.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
---
 mm/huge_memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2787cd032b0e..8237a40a7fab 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2654,7 +2654,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		}
 		khugepaged_node_load[node]++;
 		if (!PageLRU(page)) {
-			result = SCAN_SCAN_ABORT;
+			result = SCAN_PAGE_LRU;
 			goto out_unmap;
 		}
 		if (PageLocked(page)) {
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
