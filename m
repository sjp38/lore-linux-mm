Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 35D484403D7
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 11:44:48 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id z3so2357288plh.18
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 08:44:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j11si6133240pgq.502.2017.12.16.08.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 08:44:42 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 8/8] mm: Remove reference to PG_buddy
Date: Sat, 16 Dec 2017 08:44:25 -0800
Message-Id: <20171216164425.8703-9-willy@infradead.org>
In-Reply-To: <20171216164425.8703-1-willy@infradead.org>
References: <20171216164425.8703-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

PG_buddy doesn't exist any more.  It's called PageBuddy now.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index a517d210f177..06f16a451a53 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -173,13 +173,14 @@ struct page {
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
+
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
