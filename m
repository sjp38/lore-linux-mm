Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E7B896B0260
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 10:53:01 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id q12so9691150plk.16
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 07:53:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v10si11937456pgs.819.2017.12.20.07.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 07:53:00 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 4/8] mm: Improve comment on page->mapping
Date: Wed, 20 Dec 2017 07:52:52 -0800
Message-Id: <20171220155256.9841-5-willy@infradead.org>
In-Reply-To: <20171220155256.9841-1-willy@infradead.org>
References: <20171220155256.9841-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linuxfoundation.org, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The comment on page->mapping is terse, and out of date (it does not
mention the possibility of PAGE_MAPPING_MOVABLE).  Instead, point
the interested reader to page-flags.h where there is a much better
comment.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index c2294e6204e8..8c3b8cea22ee 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -50,15 +50,9 @@ struct page {
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
 	union {
-		struct address_space *mapping;	/* If low bit clear, points to
-						 * inode address_space, or NULL.
-						 * If page mapped as anonymous
-						 * memory, low bit is set, and
-						 * it points to anon_vma object
-						 * or KSM private structure. See
-						 * PAGE_MAPPING_ANON and
-						 * PAGE_MAPPING_KSM.
-						 */
+		/* See page-flags.h for the definition of PAGE_MAPPING_FLAGS */
+		struct address_space *mapping;
+
 		void *s_mem;			/* slab first object */
 		atomic_t compound_mapcount;	/* first tail page */
 		/* page_deferred_list().next	 -- second tail page */
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
