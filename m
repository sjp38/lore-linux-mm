Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 680446B006C
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 13:07:59 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so9850831wgg.13
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 10:07:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z20si16038397wij.18.2014.07.01.10.07.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 10:07:57 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v4 07/13] numa_maps: fix typo in gather_hugetbl_stats
Date: Tue,  1 Jul 2014 13:07:25 -0400
Message-Id: <1404234451-21695-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1404234451-21695-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1404234451-21695-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Just doing s/gather_hugetbl_stats/gather_hugetlb_stats/g, this makes code
grep-friendly.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git v3.16-rc3.orig/fs/proc/task_mmu.c v3.16-rc3/fs/proc/task_mmu.c
index 5ebc238d1a38..0d3d1ac32b2e 100644
--- v3.16-rc3.orig/fs/proc/task_mmu.c
+++ v3.16-rc3/fs/proc/task_mmu.c
@@ -1347,7 +1347,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 	return 0;
 }
 #ifdef CONFIG_HUGETLB_PAGE
-static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
+static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
 		unsigned long addr, unsigned long end, struct mm_walk *walk)
 {
 	struct numa_maps *md;
@@ -1366,7 +1366,7 @@ static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
 }
 
 #else
-static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
+static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
 		unsigned long addr, unsigned long end, struct mm_walk *walk)
 {
 	return 0;
@@ -1398,7 +1398,7 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 
 	md->vma = vma;
 
-	walk.hugetlb_entry = gather_hugetbl_stats;
+	walk.hugetlb_entry = gather_hugetlb_stats;
 	walk.pmd_entry = gather_pte_stats;
 	walk.private = md;
 	walk.mm = mm;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
