Subject: [PATCH] mm/slab.c - use angle brackets for include
From: Joe Perches <joe@perches.com>
Content-Type: text/plain
Date: Tue, 04 Mar 2008 16:47:15 -0800
Message-Id: <1204678035.5180.94.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

mm/slab.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 473e6c2..a37f897 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -333,7 +333,7 @@ static __always_inline int index_of(const size_t size)
 		return i; \
 	else \
 		i++;
-#include "linux/kmalloc_sizes.h"
+#include <linux/kmalloc_sizes.h>
 #undef CACHE
 		__bad_size();
 	} else



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
