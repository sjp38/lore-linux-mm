Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 6E0956B0068
	for <linux-mm@kvack.org>; Thu,  9 May 2013 05:51:25 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id xk17so570605obc.11
        for <linux-mm@kvack.org>; Thu, 09 May 2013 02:51:24 -0700 (PDT)
From: wenchaolinux@gmail.com
Subject: [RFC PATCH V1 3/6] mm : export rss vec helper functions
Date: Thu,  9 May 2013 17:50:08 +0800
Message-Id: <1368093011-4867-4-git-send-email-wenchaolinux@gmail.com>
In-Reply-To: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, hughd@google.com, walken@google.com, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, xiaoguangrong@linux.vnet.ibm.com, anthony@codemonkey.ws, stefanha@gmail.com, Wenchao Xia <wenchaolinux@gmail.com>

From: Wenchao Xia <wenchaolinux@gmail.com>

Signed-off-by: Wenchao Xia <wenchaolinux@gmail.com>
---
 include/linux/mm.h |    2 ++
 mm/memory.c        |    4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 68f52bc..5071a44 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -963,6 +963,8 @@ int walk_page_range(unsigned long addr, unsigned long end,
 		struct mm_walk *walk);
 void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
+void init_rss_vec(int *rss);
+void add_mm_rss_vec(struct mm_struct *mm, int *rss);
 unsigned long copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			   pte_t *dst_pte, pte_t *src_pte,
 			   unsigned long dst_addr, unsigned long src_addr,
diff --git a/mm/memory.c b/mm/memory.c
index 0357cf1..add1562 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -643,12 +643,12 @@ int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
 	return 0;
 }
 
-static inline void init_rss_vec(int *rss)
+void init_rss_vec(int *rss)
 {
 	memset(rss, 0, sizeof(int) * NR_MM_COUNTERS);
 }
 
-static inline void add_mm_rss_vec(struct mm_struct *mm, int *rss)
+void add_mm_rss_vec(struct mm_struct *mm, int *rss)
 {
 	int i;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
