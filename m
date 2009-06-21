Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B011E6B0082
	for <linux-mm@kvack.org>; Sun, 21 Jun 2009 10:42:25 -0400 (EDT)
Received: by pxi1 with SMTP id 1so919540pxi.12
        for <linux-mm@kvack.org>; Sun, 21 Jun 2009 07:43:45 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] remove unused line for mmap_region()
Date: Sun, 21 Jun 2009 22:43:41 +0800
Message-Id: <1245595421-3441-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

	The variable pgoff is not used in the following codes.
	So, just remove the line.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/mmap.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 34579b2..1dd6aaa 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1210,7 +1210,6 @@ munmap_back:
 	 *         f_op->mmap method. -DaveM
 	 */
 	addr = vma->vm_start;
-	pgoff = vma->vm_pgoff;
 	vm_flags = vma->vm_flags;
 
 	if (vma_wants_writenotify(vma))
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
