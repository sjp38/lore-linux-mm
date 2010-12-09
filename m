Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 43BFC6B008A
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 09:45:08 -0500 (EST)
From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] vmalloc: Remove redundant unlikely()
Date: Thu,  9 Dec 2010 15:45:04 +0100
Message-Id: <1291905904-32716-1-git-send-email-tklauser@distanz.ch>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

IS_ERR() already implies unlikely(), so it can be omitted here.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 mm/vmalloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index eb5cc7d..31dcb64 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -748,7 +748,7 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
 	va = alloc_vmap_area(VMAP_BLOCK_SIZE, VMAP_BLOCK_SIZE,
 					VMALLOC_START, VMALLOC_END,
 					node, gfp_mask);
-	if (unlikely(IS_ERR(va))) {
+	if (IS_ERR(va)) {
 		kfree(vb);
 		return ERR_CAST(va);
 	}
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
