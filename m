Date: Mon, 2 Apr 2007 16:51:00 +0200
From: Charles =?iso-8859-1?Q?Cl=E9ment?= <caratorn@gmail.com>
Subject: [KJ] [PATCH] mm: spelling error in a comment
Message-ID: <20070402145100.GA11777@tux>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernel-janitors@lists.linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Spelling fix in a comment in mm/slab.c.

Signed-off-by: Charles Clement <caratorn@gmail.com>

---

Index: linux-2.6.21-rc5/mm/slab.c
===================================================================
--- linux-2.6.21-rc5.orig/mm/slab.c
+++ linux-2.6.21-rc5/mm/slab.c
@@ -451,7 +451,7 @@ struct kmem_cache {
 
 #define BATCHREFILL_LIMIT	16
 /*
- * Optimization question: fewer reaps means less probability for unnessary
+ * Optimization question: fewer reaps means less probability for unnecessary
  * cpucache drain/refill cycles.
  *
  * OTOH the cpuarrays can contain lots of objects,

-- 
Charles Clement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
