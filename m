Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id D3FB96B003B
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 01:50:40 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id rq2so2015344pbb.2
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 22:50:40 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id e8si774652pac.111.2013.12.12.22.50.37
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 22:50:39 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 6/6] mm/migrate: remove unused function, fail_migrate_page()
Date: Fri, 13 Dec 2013 15:53:31 +0900
Message-Id: <1386917611-11319-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386917611-11319-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386917611-11319-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

fail_migrate_page() isn't used anywhere, so remove it.

Acked-by: Christoph Lameter <cl@linux.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
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
index fa73ee3..d538404 100644
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
