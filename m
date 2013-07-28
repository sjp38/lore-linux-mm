Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 0BFB06B0031
	for <linux-mm@kvack.org>; Sun, 28 Jul 2013 10:48:38 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id kp13so3702838pab.35
        for <linux-mm@kvack.org>; Sun, 28 Jul 2013 07:48:38 -0700 (PDT)
From: SeungHun Lee <waydi1@gmail.com>
Subject: [PATCH 2/2] mm: page_alloc: Add unlikely for MAX_ORDER check
Date: Sun, 28 Jul 2013 23:48:26 +0900
Message-Id: <1375022906-1164-1-git-send-email-waydi1@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: SeungHun Lee <waydi1@gmail.com>

"order >= MAX_ORDER" case is occur rarely.

So I add unlikely for this check.
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b8475ed..e644cf5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2408,7 +2408,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * be using allocators in order of preference for an area that is
 	 * too large.
 	 */
-	if (order >= MAX_ORDER) {
+	if (unlikely(order >= MAX_ORDER)) {
 		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
 		return NULL;
 	}
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
