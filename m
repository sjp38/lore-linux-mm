From: gang.chen.5i5j@gmail.com
Subject: [PATCH] mm/mmap.c: Remove useless statement "vma = NULL" in find_vma()
Date: Thu,  3 Sep 2015 11:52:26 +0800
Message-ID: <1441252346-2323-1-git-send-email-gang.chen.5i5j@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, mhocko@suse.cz
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gchen_5i5j@21cn.com, Chen Gang <gang.chen.5i5j@gmail.com>
List-Id: linux-mm.kvack.org

From: Chen Gang <gang.chen.5i5j@gmail.com>

Before the main looping, vma is already is NULL, so need not set it to
NULL, again.

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 mm/mmap.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index df6d5f0..4db7cf0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2054,7 +2054,6 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 		return vma;
 
 	rb_node = mm->mm_rb.rb_node;
-	vma = NULL;
 
 	while (rb_node) {
 		struct vm_area_struct *tmp;
-- 
1.9.3
