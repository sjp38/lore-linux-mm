Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 4881D6B0062
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 21:41:11 -0400 (EDT)
Message-ID: <4FD2A9AB.9060701@xenotime.net>
Date: Fri, 08 Jun 2012 18:40:59 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
Subject: [PATCH] mm/memory.c: fix kernel-doc warnings
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

From: Randy Dunlap <rdunlap@xenotime.net>

Fix kernel-doc warnings in mm/memory.c:

Warning(mm/memory.c:1377): No description found for parameter 'start'
Warning(mm/memory.c:1377): Excess function parameter 'address' description in 'zap_page_range'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 mm/memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-35-rc1.orig/mm/memory.c
+++ lnx-35-rc1/mm/memory.c
@@ -1366,7 +1366,7 @@ void unmap_vmas(struct mmu_gather *tlb,
 /**
  * zap_page_range - remove user pages in a given range
  * @vma: vm_area_struct holding the applicable pages
- * @address: starting address of pages to zap
+ * @start: starting address of pages to zap
  * @size: number of bytes to zap
  * @details: details of nonlinear truncation or shared cache invalidation
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
