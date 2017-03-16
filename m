Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3726B03A5
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:01:24 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 68so41342504ioh.4
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:01:24 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0193.hostedemail.com. [216.40.44.193])
        by mx.google.com with ESMTPS id d19si4701601iof.63.2017.03.15.19.01.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:01:23 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/15] mm: page_alloc: Move labels to column 1
Date: Wed, 15 Mar 2017 19:00:04 -0700
Message-Id: <91fc4b0e65b3faef751ccd7b2e6368ec4c7e1365.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Where the kernel style generally has them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dca8904bbe2e..60ec74894a56 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1528,7 +1528,7 @@ static int __init deferred_init_memmap(void *data)
 
 			/* Where possible, batch up pages for a single free */
 			continue;
-		free_range:
+free_range:
 			/* Free the current block of pages to allocator */
 			nr_pages += nr_to_free;
 			deferred_free_range(free_base_page, free_base_pfn,
@@ -3102,7 +3102,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			}
 		}
 
-	try_this_zone:
+try_this_zone:
 		page = rmqueue(ac->preferred_zoneref->zone, zone, order,
 			       gfp_mask, alloc_flags, ac->migratetype);
 		if (page) {
@@ -4160,7 +4160,7 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 	int offset;
 
 	if (unlikely(!nc->va)) {
-	refill:
+refill:
 		page = __page_frag_cache_refill(nc, gfp_mask);
 		if (!page)
 			return NULL;
@@ -5323,7 +5323,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		}
 #endif
 
-	not_early:
+not_early:
 		/*
 		 * Mark the block movable so that blocks are reserved for
 		 * movable at startup. This will force kernel allocations
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
