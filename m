Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id E35476B0037
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 14:36:12 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id a108so1180170qge.2
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:36:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r18si4646759qag.92.2014.07.11.11.36.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jul 2014 11:36:11 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v5 07/13] numa_maps: fix typo in gather_hugetbl_stats
Date: Fri, 11 Jul 2014 14:35:43 -0400
Message-Id: <1405103749-23506-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1405103749-23506-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1405103749-23506-1-git-send-email-n-horiguchi@ah.jp.nec.com>
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

diff --git mmotm-2014-07-09-17-08.orig/fs/proc/task_mmu.c mmotm-2014-07-09-17-08/fs/proc/task_mmu.c
index e4c6cdb9647b..8b1eb1617445 100644
--- mmotm-2014-07-09-17-08.orig/fs/proc/task_mmu.c
+++ mmotm-2014-07-09-17-08/fs/proc/task_mmu.c
@@ -1340,7 +1340,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 	return 0;
 }
 #ifdef CONFIG_HUGETLB_PAGE
-static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
+static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
 		unsigned long addr, unsigned long end, struct mm_walk *walk)
 {
 	struct numa_maps *md;
@@ -1359,7 +1359,7 @@ static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
 }
 
 #else
-static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
+static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
 		unsigned long addr, unsigned long end, struct mm_walk *walk)
 {
 	return 0;
@@ -1391,7 +1391,7 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 
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
