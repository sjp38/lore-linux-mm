Date: Mon, 22 Oct 2007 23:21:53 -0500
From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] Fix warning in mm/slub.c
Message-ID: <20071023042153.GA20693@lixom.net>
References: <20071018122345.514F.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071018122345.514F.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

"Make kmem_cache_node for SLUB on memory online to avoid panic" introduced
the following:

mm/slub.c:2737: warning: passing argument 1 of 'atomic_read' from
incompatible pointer type


Signed-off-by: Olof Johansson <olof@lixom.net>


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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
