Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id DFAE46B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 23:48:52 -0400 (EDT)
From: Libin <huawei.libin@huawei.com>
Subject: [PATCH] mm: Fix potential NULL pointer dereference
Date: Wed, 24 Jul 2013 11:48:19 +0800
Message-ID: <1374637699-25704-1-git-send-email-huawei.libin@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, xiaoguangrong@linux.vnet.ibm.com, wujianguo@huawei.com

find_vma may return NULL, thus check the return
value to avoid NULL pointer dereference.

Signed-off-by: Libin <huawei.libin@huawei.com>
---
 mm/huge_memory.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 243e710..d4423f4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2294,6 +2294,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out;
 
 	vma = find_vma(mm, address);
+	if (!vma)
+		goto out;
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
-- 
1.8.2.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
