Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3502B6B0268
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 10:53:08 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id z1so16660240pfl.9
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 07:53:08 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y38si11146033plh.434.2017.12.20.07.53.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 07:53:02 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 8/8] mm: Remove reference to PG_buddy
Date: Wed, 20 Dec 2017 07:52:56 -0800
Message-Id: <20171220155256.9841-9-willy@infradead.org>
In-Reply-To: <20171220155256.9841-1-willy@infradead.org>
References: <20171220155256.9841-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linuxfoundation.org, Matthew Wilcox <mawilcox@microsoft.com>

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
