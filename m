Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B7A5E6B0031
	for <linux-mm@kvack.org>; Fri,  4 Oct 2013 15:02:58 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so4420060pdi.14
        for <linux-mm@kvack.org>; Fri, 04 Oct 2013 12:02:58 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/2] smaps: show VM_SOFTDIRTY flag in VmFlags line
Date: Fri,  4 Oct 2013 15:02:14 -0400
Message-Id: <1380913335-17466-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org

This flag shows that soft dirty bit is not enabled yet.
You can enable it by "echo 4 > /proc/pid/clear_refs."

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git v3.12-rc2-mmots-2013-09-24-17-03.orig/fs/proc/task_mmu.c v3.12-rc2-mmots-2013-09-24-17-03/fs/proc/task_mmu.c
index 7366e9d..c591928 100644
--- v3.12-rc2-mmots-2013-09-24-17-03.orig/fs/proc/task_mmu.c
+++ v3.12-rc2-mmots-2013-09-24-17-03/fs/proc/task_mmu.c
@@ -561,6 +561,9 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_NONLINEAR)]	= "nl",
 		[ilog2(VM_ARCH_1)]	= "ar",
 		[ilog2(VM_DONTDUMP)]	= "dd",
+#ifdef CONFIG_MEM_SOFT_DIRTY
+		[ilog2(VM_SOFTDIRTY)]	= "sd",
+#endif
 		[ilog2(VM_MIXEDMAP)]	= "mm",
 		[ilog2(VM_HUGEPAGE)]	= "hg",
 		[ilog2(VM_NOHUGEPAGE)]	= "nh",
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
