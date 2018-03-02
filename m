Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 797E16B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 16:03:31 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t123so1481792wmt.2
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 13:03:31 -0800 (PST)
Received: from mout.web.de (mout.web.de. [212.227.17.12])
        by mx.google.com with ESMTPS id 33si4977458wrs.387.2018.03.02.13.03.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 13:03:30 -0800 (PST)
From: Mario Leinweber <marioleinweber@web.de>
Subject: [PATCH 1/1] /mm/gup.c: Fixed coding style issues.
Date: Fri,  2 Mar 2018 16:02:54 -0500
Message-Id: <20180302210254.31888-1-marioleinweber@web.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, punit.agrawal@arm.com, Mario Leinweber <marioleinweber@web.de>

- Fixed style error: 8 spaces -> 1 tab.
- Fixed style warning: Corrected misleading indentation.

Signed-off-by: Mario Leinweber <marioleinweber@web.de>
---
 mm/gup.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 1b46e6e74881..dc42c3f48e71 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -531,7 +531,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	 * reCOWed by userspace write).
 	 */
 	if ((ret & VM_FAULT_WRITE) && !(vma->vm_flags & VM_WRITE))
-	        *flags |= FOLL_COW;
+		*flags |= FOLL_COW;
 	return 0;
 }
 
@@ -1635,7 +1635,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 					 PMD_SHIFT, next, write, pages, nr))
 				return 0;
 		} else if (!gup_pte_range(pmd, addr, next, write, pages, nr))
-				return 0;
+			return 0;
 	} while (pmdp++, addr = next, addr != end);
 
 	return 1;
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
