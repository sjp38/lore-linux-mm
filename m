Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA2HMba8001096
	for <linux-mm@kvack.org>; Fri, 2 Nov 2007 13:22:37 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA2HL233476230
	for <linux-mm@kvack.org>; Fri, 2 Nov 2007 13:21:02 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA2HL1Mf008464
	for <linux-mm@kvack.org>; Fri, 2 Nov 2007 13:21:01 -0400
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 02 Nov 2007 22:50:56 +0530
Message-Id: <20071102172056.14261.39829.sendpatchset@balbir-laptop>
Subject: [PATCH] Remove unused code from mm/tiny-shmem.c
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


This code in mm/tiny-shmem.c is under #if 0, do we really need it? This
patch removes it.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/tiny-shmem.c |   12 ------------
 1 file changed, 12 deletions(-)

diff -puN mm/tiny-shmem.c~remove-unused-code mm/tiny-shmem.c
--- linux-2.6-latest/mm/tiny-shmem.c~remove-unused-code	2007-11-02 22:43:12.000000000 +0530
+++ linux-2.6-latest-balbir/mm/tiny-shmem.c	2007-11-02 22:43:30.000000000 +0530
@@ -121,18 +121,6 @@ int shmem_unuse(swp_entry_t entry, struc
 	return 0;
 }
 
-#if 0
-int shmem_mmap(struct file *file, struct vm_area_struct *vma)
-{
-	file_accessed(file);
-#ifndef CONFIG_MMU
-	return ramfs_nommu_mmap(file, vma);
-#else
-	return 0;
-#endif
-}
-#endif  /*  0  */
-
 #ifndef CONFIG_MMU
 unsigned long shmem_get_unmapped_area(struct file *file,
 				      unsigned long addr,
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
