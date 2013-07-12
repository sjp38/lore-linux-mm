Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 3A34E6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 21:44:33 -0400 (EDT)
Message-ID: <51DF5F43.3080408@asianux.com>
Date: Fri, 12 Jul 2013 09:43:31 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/slub.c: use 'unsigned long' instead of 'int' for variable
 'slub_debug'
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, mpm@selenic.com
Cc: linux-mm@kvack.org

Since all values which can be assigned to 'slub_debug' are 'unsigned
long', recommend also to define 'slub_debug' as 'unsigned long' to
match the type precisely

e.g DEBUG_DEFAULT_FLAGS, SLAB_TRACE, SLAB_FAILSLAB ...


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/slub.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 2b02d66..4fd8c50 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -452,9 +452,9 @@ static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)
  * Debug settings:
  */
 #ifdef CONFIG_SLUB_DEBUG_ON
-static int slub_debug = DEBUG_DEFAULT_FLAGS;
+static unsigned long slub_debug = DEBUG_DEFAULT_FLAGS;
 #else
-static int slub_debug;
+static unsigned long slub_debug;
 #endif
 
 static char *slub_debug_slabs;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
