Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 4F5786B0069
	for <linux-mm@kvack.org>; Thu,  9 May 2013 05:51:41 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id 6so2737231oba.32
        for <linux-mm@kvack.org>; Thu, 09 May 2013 02:51:40 -0700 (PDT)
From: wenchaolinux@gmail.com
Subject: [RFC PATCH V1 4/6] mm : export is_cow_mapping()
Date: Thu,  9 May 2013 17:50:09 +0800
Message-Id: <1368093011-4867-5-git-send-email-wenchaolinux@gmail.com>
In-Reply-To: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, hughd@google.com, walken@google.com, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, xiaoguangrong@linux.vnet.ibm.com, anthony@codemonkey.ws, stefanha@gmail.com, Wenchao Xia <wenchaolinux@gmail.com>

From: Wenchao Xia <wenchaolinux@gmail.com>

Signed-off-by: Wenchao Xia <wenchaolinux@gmail.com>
---
 include/linux/mm.h |    1 +
 mm/memory.c        |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5071a44..9bd01f5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -965,6 +965,7 @@ void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 void init_rss_vec(int *rss);
 void add_mm_rss_vec(struct mm_struct *mm, int *rss);
+bool is_cow_mapping(vm_flags_t flags);
 unsigned long copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			   pte_t *dst_pte, pte_t *src_pte,
 			   unsigned long dst_addr, unsigned long src_addr,
diff --git a/mm/memory.c b/mm/memory.c
index add1562..e5456e1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -723,7 +723,7 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
 }
 
-static inline bool is_cow_mapping(vm_flags_t flags)
+bool is_cow_mapping(vm_flags_t flags)
 {
 	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
