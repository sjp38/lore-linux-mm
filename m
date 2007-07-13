From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/7] sparsemem: clean up spelling error in comments
References: <exportbomb.1184333503@pinky>
Message-Id: <E1I9LIZ-00006Q-HD@hellhawk.shadowen.org>
Date: Fri, 13 Jul 2007 14:35:07 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/mm/sparse.c b/mm/sparse.c
index b2327e0..ec6ead6 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -101,7 +101,7 @@ static inline int sparse_index_init(unsigned long section_nr, int nid)
 
 /*
  * Although written for the SPARSEMEM_EXTREME case, this happens
- * to also work for the flat array case becase
+ * to also work for the flat array case because
  * NR_SECTION_ROOTS==NR_MEM_SECTIONS.
  */
 int __section_nr(struct mem_section* ms)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
