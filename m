Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 47D576B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 13:10:55 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id bi5so1673300pad.8
        for <linux-mm@kvack.org>; Wed, 15 May 2013 10:10:54 -0700 (PDT)
From: Zhouping Liu <sanweidaying@gmail.com>
Subject: [PATCH] mm, slab: corrected the comment 'kmem_cache_alloc' to 'slab_alloc_node'
Date: Thu, 16 May 2013 01:10:11 +0800
Message-Id: <1368637812-7329-1-git-send-email-sanweidaying@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Zhouping Liu <zliu@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org

From: Zhouping Liu <zliu@redhat.com>

commit 48356303ff(mm, slab: Rename __cache_alloc() -> slab_alloc())
forgot to update the comment 'kmem_cache_alloc' to 'slab_alloc_node'.

Signed-off-by: Zhouping Liu <zliu@redhat.com>
---
 mm/slab.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 8ccd296..8efb5f7 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3339,7 +3339,7 @@ done:
 }
 
 /**
- * kmem_cache_alloc_node - Allocate an object on the specified node
+ * slab_alloc_node - Allocate an object on the specified node
  * @cachep: The cache to allocate from.
  * @flags: See kmalloc().
  * @nodeid: node number of the target node.
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
