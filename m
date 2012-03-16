Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id C7A336B0044
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 13:23:28 -0400 (EDT)
Received: by ggeq1 with SMTP id q1so5606601gge.14
        for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:23:27 -0700 (PDT)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 1/1] TRIVIAL: mmap.c: fix comment for __insert_vm_struct()
Date: Fri, 16 Mar 2012 13:23:10 -0400
Message-Id: <1331918590-2786-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <trivial@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

The comment above __insert_vm_struct seems to suggest that this
function is also going to link the VMA with the anon_vma, but
this is not true.
This function only links the VMA to the mm->mm_rb tree and the mm->mmap linked
list.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/mmap.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index da15a79..6328a36 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -452,8 +452,8 @@ static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
 
 /*
  * Helper for vma_adjust in the split_vma insert case:
- * insert vm structure into list and rbtree and anon_vma,
- * but it has already been inserted into prio_tree earlier.
+ * insert vm structure into list and rbtree, but it has
+ * already been inserted into prio_tree earlier.
  */
 static void __insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 {
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
