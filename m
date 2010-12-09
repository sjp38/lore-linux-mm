Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 069756B0089
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 15:04:16 -0500 (EST)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 14/15] mm: Remove duplicate unlikely from IS_ERR
Date: Thu,  9 Dec 2010 12:04:07 -0800
Message-Id: <6f83d6103080eb248402114b60f6cf30c0f54db8.1291923889.git.joe@perches.com>
In-Reply-To: <1291906801-1389-2-git-send-email-tklauser@distanz.ch>
References: <1291906801-1389-2-git-send-email-tklauser@distanz.ch>
In-Reply-To: <cover.1291923888.git.joe@perches.com>
References: <cover.1291923888.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Jiri Kosina <trivial@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

IS_ERR already uses unlikely, remove unlikely from the call sites.

Signed-off-by: Joe Perches <joe@perches.com>
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
1.7.3.3.464.gf80b6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
