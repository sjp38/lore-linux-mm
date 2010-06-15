Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id ABB846B01B5
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 00:19:51 -0400 (EDT)
Date: Tue, 15 Jun 2010 13:18:13 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] refactor macros
Message-ID: <20100615041813.GA11180@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Andi-san,

Andrew and Mel gave me an improvement.
Could you put this patch on top of hwpoison branch in your tree?

Thanks,
Naoya Horiguchi
---
CONFIG_HUGETLBFS controls hugetlbfs interface code.
OTOH, CONFIG_HUGETLB_PAGE controls hugepage management code.
So we should use CONFIG_HUGETLB_PAGE here.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb_inline.h |    4 ++--
 mm/rmap.c                      |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/hugetlb_inline.h b/include/linux/hugetlb_inline.h
index cf00b6d..6931489 100644
--- a/include/linux/hugetlb_inline.h
+++ b/include/linux/hugetlb_inline.h
@@ -1,7 +1,7 @@
 #ifndef _LINUX_HUGETLB_INLINE_H
-#define _LINUX_HUGETLB_INLINE_H 1
+#define _LINUX_HUGETLB_INLINE_H
 
-#ifdef CONFIG_HUGETLBFS
+#ifdef CONFIG_HUGETLB_PAGE
 
 #include <linux/mm.h>
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 0ad5357..71bd30a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1462,7 +1462,7 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
 }
 #endif /* CONFIG_MIGRATION */
 
-#ifdef CONFIG_HUGETLBFS
+#ifdef CONFIG_HUGETLB_PAGE
 /*
  * The following three functions are for anonymous (private mapped) hugepages.
  * Unlike common anonymous pages, anonymous hugepages have no accounting code
@@ -1503,4 +1503,4 @@ void hugepage_add_new_anon_rmap(struct page *page,
 	atomic_set(&page->_mapcount, 0);
 	__hugepage_set_anon_rmap(page, vma, address, 1);
 }
-#endif /* CONFIG_HUGETLBFS */
+#endif /* CONFIG_HUGETLB_PAGE */
-- 
1.7.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
