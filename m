Date: Mon, 27 Oct 2008 08:27:32 +0800
From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH/RESEND] mm: Fix problem of parameter in note
Message-ID: <20081027002732.GA6363@ubuntu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Linux-Kernel-Mailing-List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

'current' is a pointer, so the right form is  'down_write(&current->mm->mmap_sem)'.

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 mm/mmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 74f4d15..3183990 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -904,7 +904,7 @@ void vm_stat_account(struct mm_struct *mm, unsigned long flags,
 #endif /* CONFIG_PROC_FS */
 
 /*
- * The caller must hold down_write(current->mm->mmap_sem).
+ * The caller must hold down_write(&current->mm->mmap_sem).
  */
 
 unsigned long do_mmap_pgoff(struct file * file, unsigned long addr,
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
