Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5CDB66B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 22:27:37 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id ts10so1639256obc.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 19:27:37 -0700 (PDT)
Received: from cmccmta2.chinamobile.com (cmccmta2.chinamobile.com. [221.176.66.80])
        by mx.google.com with ESMTP id f10si112395obt.98.2016.03.22.19.27.35
        for <linux-mm@kvack.org>;
        Tue, 22 Mar 2016 19:27:36 -0700 (PDT)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH 1/5] mm/hugetlb: is_vm_hugetlb_page can be boolean
Date: Wed, 23 Mar 2016 10:26:05 +0800
Message-Id: <1458699969-3432-2-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1458699969-3432-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1458699969-3432-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, rientjes@google.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, kuleshovmail@gmail.com, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, baiyaowei@cmss.chinamobile.com

This patch makes is_vm_hugetlb_page return bool to improve
readability due to this particular function only using either
one or zero as its return value.

No functional change.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 include/linux/hugetlb_inline.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/hugetlb_inline.h b/include/linux/hugetlb_inline.h
index 2bb681f..a4e7ca0 100644
--- a/include/linux/hugetlb_inline.h
+++ b/include/linux/hugetlb_inline.h
@@ -5,16 +5,16 @@
 
 #include <linux/mm.h>
 
-static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
+static inline bool is_vm_hugetlb_page(struct vm_area_struct *vma)
 {
 	return !!(vma->vm_flags & VM_HUGETLB);
 }
 
 #else
 
-static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
+static inline bool is_vm_hugetlb_page(struct vm_area_struct *vma)
 {
-	return 0;
+	return false;
 }
 
 #endif
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
