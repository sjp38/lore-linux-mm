Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 3F6906B0044
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 15:26:24 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so2254912pbb.14
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 12:26:23 -0700 (PDT)
Date: Thu, 16 Aug 2012 12:26:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, slab: remove dflags
Message-ID: <alpine.DEB.2.00.1208161225480.28427@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org

cachep->dflags is never referenced, so remove it.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/slab_def.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -45,7 +45,6 @@ struct kmem_cache {
 	unsigned int colour_off;	/* colour offset */
 	struct kmem_cache *slabp_cache;
 	unsigned int slab_size;
-	unsigned int dflags;		/* dynamic flags */
 
 	/* constructor func */
 	void (*ctor)(void *obj);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
