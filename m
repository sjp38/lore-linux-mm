Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 392286B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:34:46 -0400 (EDT)
Date: Fri, 27 May 2011 14:34:08 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] mm: fix memory.c kernel-doc notation
Message-Id: <20110527143408.891022e0.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml <linux-kernel@vger.kernel.org>
Cc: akpm <akpm@linux-foundation.org>, linux-mm@kvack.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix new kernel-doc warnings in mm/memory.c:

Warning(mm/memory.c:1327): No description found for parameter 'tlb'
Warning(mm/memory.c:1327): Excess function parameter 'tlbp' description in 'unmap_vmas'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.39-git14.orig/mm/memory.c
+++ linux-2.6.39-git14/mm/memory.c
@@ -1296,7 +1296,7 @@ static unsigned long unmap_page_range(st
 
 /**
  * unmap_vmas - unmap a range of memory covered by a list of vma's
- * @tlbp: address of the caller's struct mmu_gather
+ * @tlb: address of the caller's struct mmu_gather
  * @vma: the starting vma
  * @start_addr: virtual address at which to start unmapping
  * @end_addr: virtual address at which to end unmapping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
