Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id 561A06B00BA
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 02:37:37 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id g12so3676539oah.3
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 23:37:37 -0800 (PST)
Received: from g6t1524.atlanta.hp.com (g6t1524.atlanta.hp.com. [15.193.200.67])
        by mx.google.com with ESMTPS id iz10si2107690obb.0.2014.02.20.23.37.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Feb 2014 23:37:36 -0800 (PST)
Message-ID: <1392968254.3039.19.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH] mm: update comment in unmap_single_vma()
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 20 Feb 2014 23:37:34 -0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, davidlohr@hp.com

From: Davidlohr Bueso <davidlohr@hp.com>

The described issue now occurs inside mmap_region().
And unfortunately is still valid.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 mm/memory.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 95009f9..c90df25 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1320,9 +1320,9 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 			 * It is undesirable to test vma->vm_file as it
 			 * should be non-null for valid hugetlb area.
 			 * However, vm_file will be NULL in the error
-			 * cleanup path of do_mmap_pgoff. When
+			 * cleanup path of mmap_region. When
 			 * hugetlbfs ->mmap method fails,
-			 * do_mmap_pgoff() nullifies vma->vm_file
+			 * mmap_region() nullifies vma->vm_file
 			 * before calling this function to clean up.
 			 * Since no pte has actually been setup, it is
 			 * safe to do nothing in this case.
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
