Date: Sun, 19 Oct 2008 09:07:46 +0800
From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH] mm: fix-a-problem-of-annotation.patch
Message-ID: <20081019010746.GA6882@ubuntu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Jianjun Kong <jianjun@zeuux.org>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linux-Kernel-Mailing-List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

mm/mmap.c: fix a problem of annotation
It should be "down_write(&current->mm->mmap_sem)".

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 mm/mmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index e7a5a68..f2e4444 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -906,7 +906,7 @@ void vm_stat_account(struct mm_struct *mm, unsigned long flags,
 #endif /* CONFIG_PROC_FS */
 
 /*
- * The caller must hold down_write(current->mm->mmap_sem).
+ * The caller must hold down_write(&current->mm->mmap_sem).
  */
 
 unsigned long do_mmap_pgoff(struct file * file, unsigned long addr,
-- 
1.5.2.5

-- 
Jianjun Kong | Happy Hacking
HomePage: http://kongove.cn
Gtalk: kongjianjun@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
