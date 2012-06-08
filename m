Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 531006B0072
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 15:14:41 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so3738633obb.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 12:14:40 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v2 01/10] mm: frontswap: remove casting from function calls through ops structure
Date: Fri,  8 Jun 2012 21:15:10 +0200
Message-Id: <1339182919-11432-2-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339182919-11432-1-git-send-email-levinsasha928@gmail.com>
References: <1339182919-11432-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Removes unneeded casts.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index e250255..557e8af4 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -111,7 +111,7 @@ void __frontswap_init(unsigned type)
 	if (sis->frontswap_map == NULL)
 		return;
 	if (frontswap_enabled)
-		(*frontswap_ops.init)(type);
+		frontswap_ops.init(type);
 }
 EXPORT_SYMBOL(__frontswap_init);
 
@@ -134,7 +134,7 @@ int __frontswap_store(struct page *page)
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
 		dup = 1;
-	ret = (*frontswap_ops.store)(type, offset, page);
+	ret = frontswap_ops.store(type, offset, page);
 	if (ret == 0) {
 		frontswap_set(sis, offset);
 		inc_frontswap_succ_stores();
@@ -173,7 +173,7 @@ int __frontswap_load(struct page *page)
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
-		ret = (*frontswap_ops.load)(type, offset, page);
+		ret = frontswap_ops.load(type, offset, page);
 	if (ret == 0)
 		inc_frontswap_loads();
 	return ret;
@@ -190,7 +190,7 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
 
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset)) {
-		(*frontswap_ops.invalidate_page)(type, offset);
+		frontswap_ops.invalidate_page(type, offset);
 		atomic_dec(&sis->frontswap_pages);
 		frontswap_clear(sis, offset);
 		inc_frontswap_invalidates();
@@ -209,7 +209,7 @@ void __frontswap_invalidate_area(unsigned type)
 	BUG_ON(sis == NULL);
 	if (sis->frontswap_map == NULL)
 		return;
-	(*frontswap_ops.invalidate_area)(type);
+	frontswap_ops.invalidate_area(type);
 	atomic_set(&sis->frontswap_pages, 0);
 	memset(sis->frontswap_map, 0, sis->max / sizeof(long));
 }
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
