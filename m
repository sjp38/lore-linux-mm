Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 629B36B007E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 17:47:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so183481897pfa.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 14:47:04 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id a7si14570345pfb.39.2016.06.17.14.47.03
        for <linux-mm@kvack.org>;
        Fri, 17 Jun 2016 14:47:03 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH] THP: Fix comments of __pmd_trans_huge_lock
Date: Fri, 17 Jun 2016 14:46:36 -0700
Message-Id: <1466200004-6196-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Huang Ying <ying.huang@intel.com>

To make the comments consistent with the already changed code.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/huge_memory.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2ad52d5..641ca27 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1824,10 +1824,10 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 }
 
 /*
- * Returns true if a given pmd maps a thp, false otherwise.
+ * Returns page table lock pointer if a given pmd maps a thp, NULL otherwise.
  *
- * Note that if it returns true, this routine returns without unlocking page
- * table lock. So callers must unlock it.
+ * Note that if it returns page table lock pointer, this routine returns without
+ * unlocking page table lock. So callers must unlock it.
  */
 spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
 {
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
