Subject: [PATCH] Fix comment on #endif
From: Pascal Terjan <pterjan@mandriva.com>
Content-Type: text/plain
Date: Tue, 25 Nov 2008 15:08:19 +0100
Message-Id: <1227622099.15127.8.camel@plop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This #endif in slab.h is described as closing the inner block while it's for 
the big CONFIG_NUMA one. That makes reading the code a bit harder.

This trivial patch fixes the comment.

Signed-off-by: Pascal Terjan <pterjan@mandriva.com>
---
 include/linux/slab.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 000da12..9d8ca14 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -285,7 +285,7 @@ extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, void *);
 #define kmalloc_node_track_caller(size, flags, node) \
 	kmalloc_track_caller(size, flags)
 
-#endif /* DEBUG_SLAB */
+#endif /* CONFIG_NUMA */
 
 /*
  * Shortcuts
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
