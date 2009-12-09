Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4344260079C
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 17:42:22 -0500 (EST)
Message-ID: <4B20277B.1030903@hp.com>
Date: Wed, 09 Dec 2009 17:40:59 -0500
From: jim owens <jowens@hp.com>
MIME-Version: 1.0
Subject: [PATCH] export use_mm and unuse_mm for filesystem modules.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, mst@redhat.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


required for btrfs directio worker threads.

Signed-off-by: jim owens <jowens@hp.com>
---
 mm/mmu_context.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/mmu_context.c b/mm/mmu_context.c
index ded9081..daabf4d 100644
--- a/mm/mmu_context.c
+++ b/mm/mmu_context.c
@@ -3,6 +3,7 @@
  * See ../COPYING for licensing terms.
  */
 
+#include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/mmu_context.h>
 #include <linux/sched.h>
@@ -37,6 +38,7 @@ void use_mm(struct mm_struct *mm)
 	if (active_mm != mm)
 		mmdrop(active_mm);
 }
+EXPORT_SYMBOL_GPL(use_mm);
 
 /*
  * unuse_mm
@@ -56,3 +58,4 @@ void unuse_mm(struct mm_struct *mm)
 	enter_lazy_tlb(mm, tsk);
 	task_unlock(tsk);
 }
+EXPORT_SYMBOL_GPL(unuse_mm);
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
