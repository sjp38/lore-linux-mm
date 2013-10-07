Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5796D6B0080
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 10:15:10 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so7361114pab.32
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 07:15:10 -0700 (PDT)
Date: Mon, 07 Oct 2013 10:15:04 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1381155304-2ro6e10t-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <5252B56C.8030903@parallels.com>
References: <1380913335-17466-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5252B56C.8030903@parallels.com>
Subject: [PATCH 1/2 v2] smaps: show VM_SOFTDIRTY flag in VmFlags line
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org

On Mon, Oct 07, 2013 at 05:21:48PM +0400, Pavel Emelyanov wrote:
> On 10/04/2013 11:02 PM, Naoya Horiguchi wrote:
> > This flag shows that soft dirty bit is not enabled yet.
> > You can enable it by "echo 4 > /proc/pid/clear_refs."
> 
> The comment is not correct. Per-VMA soft-dirty flag means, that
> VMA is "newly created" one and thus represents a new (dirty) are
> in task's VM.

Thanks for the correction. I changed the description.

Naoya
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Fri, 4 Oct 2013 13:42:13 -0400
Subject: [PATCH] smaps: show VM_SOFTDIRTY flag in VmFlags line

This flag shows that the VMA is "newly created" and thus represents
"dirty" in the task's VM.
You can clear it by "echo 4 > /proc/pid/clear_refs."

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7366e9d..c591928 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
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
