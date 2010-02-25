Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 438AC6B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 01:21:45 -0500 (EST)
Received: by bwz19 with SMTP id 19so4679518bwz.6
        for <linux-mm@kvack.org>; Wed, 24 Feb 2010 22:21:45 -0800 (PST)
From: Dmitry Monakhov <dmonakhov@openvz.org>
Subject: [PATCH 1/2] slab: fix kmem_cache definition
Date: Thu, 25 Feb 2010 09:21:39 +0300
Message-Id: <1267078900-4626-1-git-send-email-dmonakhov@openvz.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: akinobu.mita@gmail.com, rientjes@google.com, Dmitry Monakhov <dmonakhov@openvz.org>
List-ID: <linux-mm.kvack.org>

SLAB_XXX flags in slab.h has defined as unsigned long.
This definition is in sync with kmem_cache->flag in slub and slob
But slab defines kmem_cache->flag as "unsigned int".

Signed-off-by: Dmitry Monakhov <dmonakhov@openvz.org>
---
 include/linux/slab_def.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index ca6b2b3..49bb71f 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -34,7 +34,7 @@ struct kmem_cache {
 	u32 reciprocal_buffer_size;
 /* 3) touched by every alloc & free from the backend */
 
-	unsigned int flags;		/* constant flags */
+	unsigned long flags;		/* constant flags */
 	unsigned int num;		/* # of objs per slab */
 
 /* 4) cache_grow/shrink */
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
