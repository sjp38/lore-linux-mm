Received: by ey-out-1920.google.com with SMTP id 21so755460eyc.44
        for <linux-mm@kvack.org>; Mon, 08 Dec 2008 18:02:35 -0800 (PST)
Date: Tue, 9 Dec 2008 05:02:27 +0300
From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] mm/memory: use uninitialized_var() macro for suppressing
	gcc warnings
Message-ID: <20081209020227.GA23948@orion>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

uninitialized_var() macro was introduced in 94909914
(Add unitialized_var() macro for suppressing gcc warnings)

mm/memory.c:1485: warning: 'ptl' may be used uninitialized in this function
mm/memory.c:561: warning: 'dst_ptl' may be used uninitialized in this function

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 mm/memory.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index fc031d6..5610a45 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -558,7 +558,7 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		unsigned long addr, unsigned long end)
 {
 	pte_t *src_pte, *dst_pte;
-	spinlock_t *src_ptl, *dst_ptl;
+	spinlock_t *src_ptl, *uninitialized_var(dst_ptl);
 	int progress = 0;
 	int rss[2];
 
@@ -1482,7 +1482,7 @@ static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
 			unsigned long pfn, pgprot_t prot)
 {
 	pte_t *pte;
-	spinlock_t *ptl;
+	spinlock_t *uninitialized_var(ptl);
 
 	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
 	if (!pte)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
