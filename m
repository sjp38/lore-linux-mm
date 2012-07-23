Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 9F24E6B005D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 15:53:33 -0400 (EDT)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [PATCH mmotm] shmem: correct build warning in shmem interleave
Date: Mon, 23 Jul 2012 14:53:31 -0500
Message-Id: <1343073211-31746-1-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, dan.carpenter@oracle.com, Nathan Zimmer <nzimmer@sgi.com>

Correcting a build warning in shmem_interleave

Signed-off-by: Nathan Zimmer <nzimmer@sgi.com>
---
 mm/shmem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index cee03c0..a38960b 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1338,7 +1338,7 @@ static unsigned long shmem_interleave(struct vm_area_struct *vma,
 	unsigned long offset;
 
 	/* Use the vm_files prefered node as the initial offset. */
-	offset = (unsigned long *) vma->vm_private_data;
+	offset = (unsigned long)vma->vm_private_data;
 
 	offset += ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
