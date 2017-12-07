Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1FEFE6B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 00:57:32 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id z1so4717335pfl.9
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 21:57:32 -0800 (PST)
Received: from huawei.com ([45.249.212.35])
        by mx.google.com with ESMTPS id n28si3470823pfg.103.2017.12.06.21.57.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 21:57:30 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH] mm/huge_memory: fix comment in __split_huge_pmd_locked
Date: Thu, 7 Dec 2017 13:49:05 +0800
Message-ID: <1512625745-59451-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, mhocko@suse.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

pmd_trans_splitting has been remove after THP refcounting redesign,
therefore related comment should be updated.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/huge_memory.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 86fe697..f2467a0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2215,10 +2215,9 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	 * for the same virtual address to be loaded simultaneously. So instead
 	 * of doing "pmd_populate(); flush_pmd_tlb_range();" we first mark the
 	 * current pmd notpresent (atomically because here the pmd_trans_huge
-	 * and pmd_trans_splitting must remain set at all times on the pmd
-	 * until the split is complete for this pmd), then we flush the SMP TLB
-	 * and finally we write the non-huge version of the pmd entry with
-	 * pmd_populate.
+	 * must remain set at all times on the pmd until the split is complete
+	 * for this pmd), then we flush the SMP TLB and finally we write the
+	 * non-huge version of the pmd entry with pmd_populate.
 	 */
 	pmdp_invalidate(vma, haddr, pmd);
 	pmd_populate(mm, pmd, pgtable);
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
