Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id A6D316B0256
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 01:52:43 -0500 (EST)
Received: by obbww6 with SMTP id ww6so115123039obb.0
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 22:52:43 -0800 (PST)
Received: from cmccmta1.chinamobile.com (cmccmta1.chinamobile.com. [221.176.66.79])
        by mx.google.com with ESMTP id z8si19975527obk.95.2015.11.15.22.52.42
        for <linux-mm@kvack.org>;
        Sun, 15 Nov 2015 22:52:42 -0800 (PST)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH 4/7] mm/vmscan: page_is_file_cache can be boolean
Date: Mon, 16 Nov 2015 14:51:23 +0800
Message-Id: <1447656686-4851-5-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mhocko@suse.cz, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch makes page_is_file_cache return bool to improve
readability due to this particular function only using either
one or zero as its return value.

No functional change.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 include/linux/mm_inline.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index cf55945..af73135 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -8,8 +8,8 @@
  * page_is_file_cache - should the page be on a file LRU or anon LRU?
  * @page: the page to test
  *
- * Returns 1 if @page is page cache page backed by a regular filesystem,
- * or 0 if @page is anonymous, tmpfs or otherwise ram or swap backed.
+ * Returns true if @page is page cache page backed by a regular filesystem,
+ * or false if @page is anonymous, tmpfs or otherwise ram or swap backed.
  * Used by functions that manipulate the LRU lists, to sort a page
  * onto the right LRU list.
  *
@@ -17,7 +17,7 @@
  * needs to survive until the page is last deleted from the LRU, which
  * could be as far down as __page_cache_release.
  */
-static inline int page_is_file_cache(struct page *page)
+static inline bool page_is_file_cache(struct page *page)
 {
 	return !PageSwapBacked(page);
 }
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
