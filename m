Date: Mon, 29 Oct 2007 13:15:40 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] slub: nr_slabs is an atomic_long_t
Message-Id: <20071029131540.13932677.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

so shouldn't be passed to atomic_read.

mm/slub.c: In function 'slab_mem_offline_callback':
mm/slub.c:2737: warning: passing argument 1 of 'atomic_read' from incompatible pointer type
mm/slub.c:2737: warning: passing argument 1 of 'atomic_read' from incompatible pointer type
mm/slub.c:2737: warning: passing argument 1 of 'atomic_read' from incompatible pointer type

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 mm/slub.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

Seen on PowerPC allyesconfig build.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/mm/slub.c b/mm/slub.c
index aac1dd3..bcdb2c8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2734,7 +2734,7 @@ static void slab_mem_offline_callback(void *arg)
 			 * and offline_pages() function shoudn't call this
 			 * callback. So, we must fail.
 			 */
-			BUG_ON(atomic_read(&n->nr_slabs));
+			BUG_ON(atomic_long_read(&n->nr_slabs));
 
 			s->node[offline_node] = NULL;
 			kmem_cache_free(kmalloc_caches, n);
-- 
1.5.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
