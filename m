Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 153946B00F2
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 02:57:14 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so872729bkw.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 23:57:13 -0700 (PDT)
Subject: [PATCH 14/16] mm/score: use vm_flags_t for vma flags
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 21 Mar 2012 10:57:10 +0400
Message-ID: <20120321065710.13852.36939.stgit@zurg>
In-Reply-To: <20120321065140.13852.52315.stgit@zurg>
References: <20120321065140.13852.52315.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lennox Wu <lennox.wu@gmail.com>, Chen Liqin <liqin.chen@sunplusct.com>

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Chen Liqin <liqin.chen@sunplusct.com>
Cc: Lennox Wu <lennox.wu@gmail.com>
---
 arch/score/mm/cache.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/score/mm/cache.c b/arch/score/mm/cache.c
index b25e957..2288ffc 100644
--- a/arch/score/mm/cache.c
+++ b/arch/score/mm/cache.c
@@ -79,7 +79,7 @@ void __update_cache(struct vm_area_struct *vma, unsigned long address,
 {
 	struct page *page;
 	unsigned long pfn, addr;
-	int exec = (vma->vm_flags & VM_EXEC);
+	int exec = (vma->vm_flags & VM_EXEC) != VM_NONE;
 
 	pfn = pte_pfn(pte);
 	if (unlikely(!pfn_valid(pfn)))
@@ -172,7 +172,7 @@ void flush_cache_range(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	int exec = vma->vm_flags & VM_EXEC;
+	int exec = (vma->vm_flags & VM_EXEC) != VM_NONE;
 	pgd_t *pgdp;
 	pud_t *pudp;
 	pmd_t *pmdp;
@@ -210,7 +210,7 @@ void flush_cache_range(struct vm_area_struct *vma,
 void flush_cache_page(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long pfn)
 {
-	int exec = vma->vm_flags & VM_EXEC;
+	int exec = (vma->vm_flags & VM_EXEC) != VM_NONE;
 	unsigned long kaddr = 0xa0000000 | (pfn << PAGE_SHIFT);
 
 	flush_dcache_range(kaddr, kaddr + PAGE_SIZE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
