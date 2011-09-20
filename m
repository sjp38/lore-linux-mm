Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D41AA9000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 14:32:57 -0400 (EDT)
Date: Tue, 20 Sep 2011 14:32:55 -0400
From: Dean Nelson <dnelson@redhat.com>
Message-Id: <20110920183254.3926.59134.email-sent-by-dnelson@localhost6.localdomain6>
Subject: [PATCH] HWPOISON: Convert pr_debug()s to pr_info()s
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

Commit fb46e73520940bfc426152cfe5e4a9f1ae3f00b6 authored by Andi Kleen
converted a number of pr_debug()s to pr_info()s.

About the same time additional code with pr_debug()s was added by
two other commits 8c6c2ecb44667f7204e9d2b89c4c1f42edc5a196 and
d950b95882f3dc47e86f1496cd3f7fef540d6d6b. And these pr_debug()s
failed to get converted to pr_info()s.

This patch converts them as well. And does some minor related
whitespace cleanup.

Signed-off-by: Dean Nelson <dnelson@redhat.com>

---
 mm/memory-failure.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 2b43ba0..edc388d 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1310,7 +1310,7 @@ int unpoison_memory(unsigned long pfn)
 		 * to the end.
 		 */
 		if (PageHuge(page)) {
-			pr_debug("MCE: Memory failure is now running on free hugepage %#lx\n", pfn);
+			pr_info("MCE: Memory failure is now running on free hugepage %#lx\n", pfn);
 			return 0;
 		}
 		if (TestClearPageHWPoison(p))
@@ -1419,7 +1419,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 
 	if (PageHWPoison(hpage)) {
 		put_page(hpage);
-		pr_debug("soft offline: %#lx hugepage already poisoned\n", pfn);
+		pr_info("soft offline: %#lx hugepage already poisoned\n", pfn);
 		return -EBUSY;
 	}
 
@@ -1433,8 +1433,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
 		list_for_each_entry_safe(page1, page2, &pagelist, lru)
 			put_page(page1);
 
-		pr_debug("soft offline: %#lx: migration failed %d, type %lx\n",
-			 pfn, ret, page->flags);
+		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
+			pfn, ret, page->flags);
 		if (ret > 0)
 			ret = -EIO;
 		return ret;
@@ -1505,7 +1505,7 @@ int soft_offline_page(struct page *page, int flags)
 	}
 	if (!PageLRU(page)) {
 		pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
-				pfn, page->flags);
+			pfn, page->flags);
 		return -EIO;
 	}
 
@@ -1566,7 +1566,7 @@ int soft_offline_page(struct page *page, int flags)
 		}
 	} else {
 		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx\n",
-				pfn, ret, page_count(page), page->flags);
+			pfn, ret, page_count(page), page->flags);
 	}
 	if (ret)
 		return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
