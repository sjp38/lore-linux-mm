From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/8] sparsemem: clean up spelling error in comments
References: <exportbomb.1179873917@pinky>
Message-Id: <E1HqdJC-0003d4-Pa@hellhawk.shadowen.org>
Date: Tue, 22 May 2007 23:58:26 +0100
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
index cb105a6..caa7e1b 100644
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
