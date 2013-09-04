Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 1251C6B0032
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 09:30:52 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so301212pbc.22
        for <linux-mm@kvack.org>; Wed, 04 Sep 2013 06:30:51 -0700 (PDT)
From: Jianguo Wu <wujianguo106@gmail.com>
Subject: [PATCH] mm/thp: fix comments in transparent_hugepage_flags
Date: Wed,  4 Sep 2013 21:30:22 +0800
Message-Id: <1378301422-9468-1-git-send-email-wujianguo@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, xiaoguangrong@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jianguo Wu <wujianguo@huawei.com>

Since commit d39d33c332(thp: enable direct defrag), defrag is enable
for all transparent hugepage page faults by default, not only in
MADV_HUGEPAGE regions.

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/huge_memory.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a92012a..abf047e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -28,10 +28,8 @@
 
 /*
  * By default transparent hugepage support is enabled for all mappings
- * and khugepaged scans all mappings. Defrag is only invoked by
- * khugepaged hugepage allocations and by page faults inside
- * MADV_HUGEPAGE regions to avoid the risk of slowing down short lived
- * allocations.
+ * and khugepaged scans all mappings. Defrag is invoked by khugepaged
+ * hugepage allocations and by page faults for all hugepage allocations.
  */
 unsigned long transparent_hugepage_flags __read_mostly =
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
