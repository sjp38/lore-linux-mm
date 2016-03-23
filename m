Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id CBD696B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 22:30:23 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id 4so4366762pfd.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 19:30:23 -0700 (PDT)
Received: from cmccmta1.chinamobile.com (cmccmta1.chinamobile.com. [221.176.66.79])
        by mx.google.com with ESMTP id fe1si540266pac.200.2016.03.22.19.30.22
        for <linux-mm@kvack.org>;
        Tue, 22 Mar 2016 19:30:22 -0700 (PDT)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH 3/5] mm/vmalloc: is_vmalloc_addr can be boolean
Date: Wed, 23 Mar 2016 10:26:07 +0800
Message-Id: <1458699969-3432-4-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1458699969-3432-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1458699969-3432-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, rientjes@google.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, kuleshovmail@gmail.com, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, baiyaowei@cmss.chinamobile.com

This patch makes is_vmalloc_addr return bool to improve
readability due to this particular function only using either
one or zero as its return value.

No functional change.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 include/linux/mm.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index dbf1edd..826d2fb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -400,14 +400,14 @@ unsigned long vmalloc_to_pfn(const void *addr);
  * On nommu, vmalloc/vfree wrap through kmalloc/kfree directly, so there
  * is no special casing required.
  */
-static inline int is_vmalloc_addr(const void *x)
+static inline bool is_vmalloc_addr(const void *x)
 {
 #ifdef CONFIG_MMU
 	unsigned long addr = (unsigned long)x;
 
 	return addr >= VMALLOC_START && addr < VMALLOC_END;
 #else
-	return 0;
+	return false;
 #endif
 }
 #ifdef CONFIG_MMU
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
