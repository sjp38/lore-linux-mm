Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 326996B0062
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 05:21:50 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MCF00IL6ZASRNX0@mailout4.samsung.com> for
 linux-mm@kvack.org; Thu, 25 Oct 2012 18:21:35 +0900 (KST)
Received: from DOJG1HAN02 ([12.23.120.99])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MCF00EC5ZBY5B20@mmp2.samsung.com> for linux-mm@kvack.org;
 Thu, 25 Oct 2012 18:21:35 +0900 (KST)
From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] mm: fix build warning in try_to_unmap_cluster()
Date: Thu, 25 Oct 2012 18:21:34 +0900
Message-id: <000f01cdb292$20df5910$629e0b30$%han@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, 'Bob Liu' <lliubbo@gmail.com>, 'Jingoo Han' <jg1.han@samsung.com>

Fix build warning in try_to_unmap_cluster() as below:

mm/rmap.c: In function 'try_to_unmap_cluster':
mm/rmap.c:1364:9: warning: unused variable 'pud' [-Wunused-variable]
mm/rmap.c:1363:9: warning: unused variable 'pgd' [-Wunused-variable]

This build warning is introduced by commit 0981230
"mm: introduce mm_find_pmd()".

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
Cc: Bob Liu <lliubbo@gmail.com>
---
This patch is based on linux-next-20121025 code tree.

 mm/rmap.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 6c686c2..98b100e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1360,8 +1360,6 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 		struct vm_area_struct *vma, struct page *check_page)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	pgd_t *pgd;
-	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 	pte_t pteval;
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
