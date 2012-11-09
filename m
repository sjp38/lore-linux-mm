Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id C40516B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 02:41:30 -0500 (EST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MD700JHKMP51DW0@mailout2.samsung.com> for
 linux-mm@kvack.org; Fri, 09 Nov 2012 16:41:29 +0900 (KST)
Received: from DOJG1HAN02 ([12.23.120.99])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MD700HR9MP46J20@mmp2.samsung.com> for linux-mm@kvack.org;
 Fri, 09 Nov 2012 16:41:29 +0900 (KST)
From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] mm: mmap: remove unused variable
Date: Fri, 09 Nov 2012 16:41:28 +0900
Message-id: <000101cdbe4d$a1335eb0$e39a1c10$%han@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, 'Jingoo Han' <jg1.han@samsung.com>

Fixed build warning as below:

arch/arm/mm/mmap.c: In function 'arch_get_unmapped_area':
arch/arm/mm/mmap.c:60:16: warning: unused variable 'start_addr' [-Wunused-variable]

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
This patch is based on linux-next-20121109 code tree.

 arch/arm/mm/mmap.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index f4fec6d..10062ce 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -57,7 +57,6 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
-	unsigned long start_addr;
 	int do_align = 0;
 	int aliasing = cache_is_vipt_aliasing();
 	struct vm_unmapped_area_info info;
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
