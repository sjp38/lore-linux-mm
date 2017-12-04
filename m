Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22A386B0299
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 08:35:45 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id 18so11768732qtt.10
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 05:35:45 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v33si2022976qtk.21.2017.12.04.05.35.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 05:35:44 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vB4DZ1gS010472
	for <linux-mm@kvack.org>; Mon, 4 Dec 2017 08:35:43 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2en4h71dvc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:35:42 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 4 Dec 2017 13:35:38 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] mm: update comment describing tlb_gather_mmu
Date: Mon,  4 Dec 2017 15:35:31 +0200
Message-Id: <1512394531-2264-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The comment describes @fullmm argument, but the function have no such
parameter.

Update the comment to match the code and convert it to kernel-doc markup.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---

When I tried to see the result of the markup conversion, I've found that
most of the mm documentation is marked as :export: in kernel-api.rst.
Is this intentional?

 mm/memory.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 5eb3d2524bdc..3b445f2062d5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -400,10 +400,17 @@ void tlb_remove_table(struct mmu_gather *tlb, void *table)
 
 #endif /* CONFIG_HAVE_RCU_TABLE_FREE */
 
-/* tlb_gather_mmu
- *	Called to initialize an (on-stack) mmu_gather structure for page-table
- *	tear-down from @mm. The @fullmm argument is used when @mm is without
- *	users and we're going to destroy the full address space (exit/execve).
+/**
+ * tlb_gather_mmu - initialize an mmu_gather structure for page-table tear-down
+ * @tlb: the mmu_gather structure to initialize
+ * @mm: the mm_struct of the target address space
+ * @start: start of the region that will be removed from the page-table
+ * @end: end of the region that will be removed from the page-table
+ *
+ * Called to initialize an (on-stack) mmu_gather structure for page-table
+ * tear-down from @mm. The @start and @end are set to 0 and -1
+ * respectively when @mm is without users and we're going to destroy
+ * the full address space (exit/execve).
  */
 void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 			unsigned long start, unsigned long end)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
