Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 51DA16B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 21:27:04 -0500 (EST)
From: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Subject: [PATCH] mm: remove redundant var retval in sys_brk
Date: Sat,  5 Jan 2013 10:27:44 +0800
Message-Id: <1357352864-29258-1-git-send-email-yuanhan.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yuanhan Liu <yuanhan.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

There is only one possible return value of sys_brk, which is mm->brk no
matter succeed or not.

Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yuanhan Liu <yuanhan.liu@linux.intel.com>
---
 mm/mmap.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f54b235..ae4093c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -251,7 +251,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len);
 
 SYSCALL_DEFINE1(brk, unsigned long, brk)
 {
-	unsigned long rlim, retval;
+	unsigned long rlim;
 	unsigned long newbrk, oldbrk;
 	struct mm_struct *mm = current->mm;
 	unsigned long min_brk;
@@ -307,9 +307,8 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 set_brk:
 	mm->brk = brk;
 out:
-	retval = mm->brk;
 	up_write(&mm->mmap_sem);
-	return retval;
+	return mm->brk;
 }
 
 static long vma_compute_subtree_gap(struct vm_area_struct *vma)
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
