Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7BC6B0035
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 12:24:21 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id la4so11569959vcb.37
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 09:24:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r9si29302853qcj.46.2014.08.04.09.24.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Aug 2014 09:24:19 -0700 (PDT)
Date: Mon, 4 Aug 2014 11:50:08 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm/hugetlb: remove unused argument of follow_huge_(pmd|pud)
Message-ID: <20140804155008.GA9323@nhori.bos.redhat.com>
References: <1406914663-8631-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140801145358.0d673fc05235d941ca9dec0e@linux-foundation.org>
 <20140801215845.GA18622@nhori.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140801215845.GA18622@nhori.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Aug 01, 2014 at 05:58:45PM -0400, Naoya Horiguchi wrote:
...
> > I can't find an implementation of follow_huge_pmd() which actually uses
> > the fourth argument "write".  Zap?
> 
> OK, I'll post it later.

Here is the patch.

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Mon, 4 Aug 2014 11:30:00 -0400
Subject: [PATCH] mm/hugetlb: remove unused argument of follow_huge_(pmd|pud)

There is no implementation of follow_huge_pmd() which actually uses
the fourth argument "write". So let's zap it.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/ia64/mm/hugetlbpage.c    |  2 +-
 arch/metag/mm/hugetlbpage.c   |  2 +-
 arch/mips/mm/hugetlbpage.c    |  2 +-
 arch/powerpc/mm/hugetlbpage.c |  2 +-
 arch/s390/mm/hugetlbpage.c    |  2 +-
 arch/sh/mm/hugetlbpage.c      |  2 +-
 arch/sparc/mm/hugetlbpage.c   |  2 +-
 arch/tile/mm/hugetlbpage.c    |  4 ++--
 arch/x86/mm/hugetlbpage.c     |  2 +-
 include/linux/hugetlb.h       |  8 ++++----
 mm/gup.c                      |  2 +-
 mm/hugetlb.c                  | 11 ++++-------
 12 files changed, 19 insertions(+), 22 deletions(-)

diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
index 76069c18ee42..d14ae6804106 100644
--- a/arch/ia64/mm/hugetlbpage.c
+++ b/arch/ia64/mm/hugetlbpage.c
@@ -115,7 +115,7 @@ int pud_huge(pud_t pud)
 }
 
 struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address, pmd_t *pmd, int write)
+follow_huge_pmd(struct mm_struct *mm, unsigned long address, pmd_t *pmd)
 {
 	return NULL;
 }
diff --git a/arch/metag/mm/hugetlbpage.c b/arch/metag/mm/hugetlbpage.c
index 3c52fa6d0f8e..e2559b12f6aa 100644
--- a/arch/metag/mm/hugetlbpage.c
+++ b/arch/metag/mm/hugetlbpage.c
@@ -111,7 +111,7 @@ int pud_huge(pud_t pud)
 }
 
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmd, int write)
+			     pmd_t *pmd)
 {
 	return NULL;
 }
diff --git a/arch/mips/mm/hugetlbpage.c b/arch/mips/mm/hugetlbpage.c
index 4ec8ee10d371..690749184d0f 100644
--- a/arch/mips/mm/hugetlbpage.c
+++ b/arch/mips/mm/hugetlbpage.c
@@ -86,7 +86,7 @@ int pud_huge(pud_t pud)
 
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+		pmd_t *pmd)
 {
 	struct page *page;
 
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 7e70ae968e5f..8339978033ad 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -700,7 +700,7 @@ follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
 
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+		pmd_t *pmd)
 {
 	BUG();
 	return NULL;
diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index 0ff66a7e29bb..abbdee629790 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -221,7 +221,7 @@ int pud_huge(pud_t pud)
 }
 
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmdp, int write)
+			     pmd_t *pmdp)
 {
 	struct page *page;
 
diff --git a/arch/sh/mm/hugetlbpage.c b/arch/sh/mm/hugetlbpage.c
index d7762349ea48..1f636ed3ffcd 100644
--- a/arch/sh/mm/hugetlbpage.c
+++ b/arch/sh/mm/hugetlbpage.c
@@ -84,7 +84,7 @@ int pud_huge(pud_t pud)
 }
 
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmd, int write)
+			     pmd_t *pmd)
 {
 	return NULL;
 }
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index d329537739c6..4cb2b4820bd5 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -232,7 +232,7 @@ int pud_huge(pud_t pud)
 }
 
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmd, int write)
+			     pmd_t *pmd)
 {
 	return NULL;
 }
diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
index e514899e1100..3c07a555b9b9 100644
--- a/arch/tile/mm/hugetlbpage.c
+++ b/arch/tile/mm/hugetlbpage.c
@@ -167,7 +167,7 @@ int pud_huge(pud_t pud)
 }
 
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-			     pmd_t *pmd, int write)
+			     pmd_t *pmd)
 {
 	struct page *page;
 
@@ -178,7 +178,7 @@ struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 }
 
 struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
-			     pud_t *pud, int write)
+			     pud_t *pud)
 {
 	struct page *page;
 
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 8b977ebf9388..fc72bb59141c 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -54,7 +54,7 @@ int pud_huge(pud_t pud)
 
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+		pmd_t *pmd)
 {
 	return NULL;
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 194834853d6f..3a8b338ff84a 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -98,9 +98,9 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 			      int write);
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-				pmd_t *pmd, int write);
+				pmd_t *pmd);
 struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
-				pud_t *pud, int write);
+				pud_t *pud);
 struct page *follow_huge_pmd_lock(struct vm_area_struct *vma,
 				unsigned long address, pmd_t *pmd, int flags);
 int pmd_huge(pmd_t pmd);
@@ -134,8 +134,8 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
 static inline void hugetlb_show_meminfo(void)
 {
 }
-#define follow_huge_pmd(mm, addr, pmd, write)	NULL
-#define follow_huge_pud(mm, addr, pud, write)	NULL
+#define follow_huge_pmd(mm, addr, pmd)	NULL
+#define follow_huge_pud(mm, addr, pud)	NULL
 #define follow_huge_pmd_lock(vma, addr, pmd, flags)	NULL
 #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
 #define pmd_huge(x)	0
diff --git a/mm/gup.c b/mm/gup.c
index e4bd59efe686..57e394e33e66 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -165,7 +165,7 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
 		if (flags & FOLL_GET)
 			return NULL;
-		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
+		page = follow_huge_pud(mm, address, pud);
 		return page;
 	}
 	if (unlikely(pud_bad(*pud)))
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 923465c0b47f..4f6d1a4f5339 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3657,8 +3657,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 }
 
 struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
+follow_huge_pmd(struct mm_struct *mm, unsigned long address, pmd_t *pmd)
 {
 	struct page *page;
 
@@ -3669,8 +3668,7 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 }
 
 struct page *
-follow_huge_pud(struct mm_struct *mm, unsigned long address,
-		pud_t *pud, int write)
+follow_huge_pud(struct mm_struct *mm, unsigned long address, pud_t *pud)
 {
 	struct page *page;
 
@@ -3684,8 +3682,7 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 
 /* Can be overriden by architectures */
 struct page * __weak
-follow_huge_pud(struct mm_struct *mm, unsigned long address,
-	       pud_t *pud, int write)
+follow_huge_pud(struct mm_struct *mm, unsigned long address, pud_t *pud)
 {
 	BUG();
 	return NULL;
@@ -3710,7 +3707,7 @@ struct page *follow_huge_pmd_lock(struct vm_area_struct *vma,
 	if (flags & FOLL_GET)
 		ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pmd);
 
-	page = follow_huge_pmd(vma->vm_mm, address, pmd, flags & FOLL_WRITE);
+	page = follow_huge_pmd(vma->vm_mm, address, pmd);
 
 	if (flags & FOLL_GET) {
 		/*
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
