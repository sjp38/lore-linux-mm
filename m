Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id CC9966B0081
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 04:08:06 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so5036254pbb.36
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 01:08:06 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id sw1si6670475pbc.222.2013.12.09.01.08.04
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 01:08:05 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 6/7] mm/migrate: remove unused function, fail_migrate_page()
Date: Mon,  9 Dec 2013 18:10:47 +0900
Message-Id: <1386580248-22431-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

fail_migrate_page() isn't used anywhere, so remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index e4671f9..4308018 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -41,9 +41,6 @@ extern int migrate_page(struct address_space *,
 extern int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, enum migrate_mode mode, int reason);
 
-extern int fail_migrate_page(struct address_space *,
-			struct page *, struct page *);
-
 extern int migrate_prep(void);
 extern int migrate_prep_local(void);
 extern int migrate_vmas(struct mm_struct *mm,
@@ -83,7 +80,6 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 
 /* Possible settings for the migrate_page() method in address_operations */
 #define migrate_page NULL
-#define fail_migrate_page NULL
 
 #endif /* CONFIG_MIGRATION */
 
diff --git a/mm/migrate.c b/mm/migrate.c
index cdafdc0..b595f89 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -550,14 +550,6 @@ void migrate_page_copy(struct page *newpage, struct page *page)
  *                    Migration functions
  ***********************************************************/
 
-/* Always fail migration. Used for mappings that are not movable */
-int fail_migrate_page(struct address_space *mapping,
-			struct page *newpage, struct page *page)
-{
-	return -EIO;
-}
-EXPORT_SYMBOL(fail_migrate_page);
-
 /*
  * Common logic to directly migrate a single page suitable for
  * pages that do not use PagePrivate/PagePrivate2.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
