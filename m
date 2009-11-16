Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D714B6B004D
	for <linux-mm@kvack.org>; Mon, 16 Nov 2009 01:07:03 -0500 (EST)
From: Vincent Li <macli@brc.ubc.ca>
Subject: [PATCH] vmscan: correct comment type error in scan_zone_unevictable_pages
Date: Sun, 15 Nov 2009 22:07:07 -0800
Message-Id: <1258351627-25186-1-git-send-email-macli@brc.ubc.ca>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Vincent Li <macli@brc.ubc.ca>
List-ID: <linux-mm.kvack.org>

...Move those that have to @zone's inactive list...

Signed-off-by: Vincent Li <macli@brc.ubc.ca>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index abb6a4b..371c97d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2790,7 +2790,7 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
  * @zone - zone of which to scan the unevictable list
  *
  * Scan @zone's unevictable LRU lists to check for pages that have become
- * evictable.  Move those that have to @zone's inactive list where they
+ * evictable.  Move those to @zone's inactive list where they
  * become candidates for reclaim, unless shrink_inactive_zone() decides
  * to reactivate them.  Pages that are still unevictable are rotated
  * back onto @zone's unevictable list.
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
