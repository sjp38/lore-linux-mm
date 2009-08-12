Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CE0F26B005A
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 04:32:14 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/5] mm: document is_page_cache_freeable()
Date: Wed, 12 Aug 2009 10:32:09 +0200
Message-Id: <1250065929-17392-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1250065929-17392-1-git-send-email-hannes@cmpxchg.org>
References: <1250065929-17392-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Enlighten the reader of this code about what reference count makes a
page cache page freeable.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 mm/vmscan.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

v2: describe reference holders a bit better [thanks, Christoph]

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4904986..5bb1055 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -286,6 +286,11 @@ static inline int page_mapping_inuse(struct page *page)
 
 static inline int is_page_cache_freeable(struct page *page)
 {
+	/*
+	 * A freeable page cache page is referenced only by the caller
+	 * that isolated the page, the page cache radix tree and
+	 * optional buffer heads at page->private.
+	 */
 	return page_count(page) - page_has_private(page) == 2;
 }
 
-- 
1.6.4.13.ge6580

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
