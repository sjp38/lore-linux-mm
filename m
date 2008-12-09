Date: Tue, 9 Dec 2008 19:06:30 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] fix coding style of mm/mmap.c
In-Reply-To: <20081209075652.GA3515@helight>
Message-ID: <Pine.LNX.4.64.0812091837380.28534@blonde.anvils>
References: <20081209075652.GA3515@helight>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Helight.Xu" <zhwenxu@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ZhenwenXu <helight.xu@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Okay, thanks for this.

Though, to be honest, we're not all that keen on random cleanups of
this kind: they can cause more trouble than they're worth, when real
development is going on in the area - better leave them to those who
are working on bigger changes nearby.

But mm/mmap.c is currently the same in mmotm as in Linus's git
(though slightly different from the 2.6.27 version in your patch -
I've rediffed it below), so it shouldn't cause anyone much trouble:
Andrew, please add to mmotm.  (scripts/checkpatch.pl does warn on
the long acct_stack_growth line, but Zhenwen has made it a little
shorter, and people disagree about long function declaration lines.)

Please inline your patches in future, so all can see them at a glance:
ah, you're using gmail, yes, that does mess them up - I believe there's
advice on how to configure it for sending Linux patches somewhere in
the archives, but I didn't find it in Documentation/SubmittingPatches
just now, sorry.

Hugh


[PATCH] fix coding style of mm/mmap.c

From: ZhenwenXu <helight.xu@gmail.com>

Fix a little of the coding style in mm/mmap.c 

Signed-off-by: ZhenwenXu <helight.xu@gmail.com>
Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/mmap.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -413,7 +413,7 @@ void __vma_link_rb(struct mm_struct *mm,
 
 static void __vma_link_file(struct vm_area_struct *vma)
 {
-	struct file * file;
+	struct file *file;
 
 	file = vma->vm_file;
 	if (file) {
@@ -475,10 +475,10 @@ static void vma_link(struct mm_struct *m
  * but it has already been inserted into prio_tree earlier.
  */
 static void
-__insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
+__insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 {
-	struct vm_area_struct * __vma, * prev;
-	struct rb_node ** rb_link, * rb_parent;
+	struct vm_area_struct *__vma, *prev;
+	struct rb_node **rb_link, *rb_parent;
 
 	__vma = find_vma_prepare(mm, vma->vm_start,&prev, &rb_link, &rb_parent);
 	BUG_ON(__vma && __vma->vm_start < vma->vm_end);
@@ -908,7 +908,7 @@ void vm_stat_account(struct mm_struct *m
  * The caller must hold down_write(current->mm->mmap_sem).
  */
 
-unsigned long do_mmap_pgoff(struct file * file, unsigned long addr,
+unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 			unsigned long len, unsigned long prot,
 			unsigned long flags, unsigned long pgoff)
 {
@@ -1464,7 +1464,7 @@ get_unmapped_area(struct file *file, uns
 EXPORT_SYMBOL(get_unmapped_area);
 
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
-struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr)
+struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 {
 	struct vm_area_struct *vma = NULL;
 
@@ -1507,7 +1507,7 @@ find_vma_prev(struct mm_struct *mm, unsi
 			struct vm_area_struct **pprev)
 {
 	struct vm_area_struct *vma = NULL, *prev = NULL;
-	struct rb_node * rb_node;
+	struct rb_node *rb_node;
 	if (!mm)
 		goto out;
 
@@ -1541,7 +1541,7 @@ out:
  * update accounting. This is shared with both the
  * grow-up and grow-down cases.
  */
-static int acct_stack_growth(struct vm_area_struct * vma, unsigned long size, unsigned long grow)
+static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, unsigned long grow)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct rlimit *rlim = current->signal->rlim;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
