Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B8D686B0273
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 10:56:04 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v190so14492323pgv.11
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 07:56:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a20si13364114pfg.38.2017.12.20.07.56.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 07:56:03 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 8/8] mm: Remove reference to PG_buddy
Date: Wed, 20 Dec 2017 07:55:52 -0800
Message-Id: <20171220155552.15884-9-willy@infradead.org>
In-Reply-To: <20171220155552.15884-1-willy@infradead.org>
References: <20171220155552.15884-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linuxfoundation.org, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

PG_buddy doesn't exist any more.  It's called PageBuddy now.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 include/linux/mm_types.h | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ef35ea524c26..9b154b4e912e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -174,13 +174,13 @@ struct page {
 	};
 
 	union {
-		unsigned long private;		/* Mapping-private opaque data:
-					 	 * usually used for buffer_heads
-						 * if PagePrivate set; used for
-						 * swp_entry_t if PageSwapCache;
-						 * indicates order in the buddy
-						 * system if PG_buddy is set.
-						 */
+		/*
+		 * Mapping-private opaque data:
+		 * Usually used for buffer_heads if PagePrivate
+		 * Used for swp_entry_t if PageSwapCache
+		 * Indicates order in the buddy system if PageBuddy
+		 */
+		unsigned long private;
 #if USE_SPLIT_PTE_PTLOCKS
 #if ALLOC_SPLIT_PTLOCKS
 		spinlock_t *ptl;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
