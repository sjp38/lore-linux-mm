Date: Fri, 26 Jan 2007 12:01:13 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] typeof __page_to_pfn with SPARSEMEM=y
Message-Id: <20070126120113.c17c1174.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

With CONFIG_SPARSEMEM=y:

mm/rmap.c:579: warning: format '%lx' expects type 'long unsigned int', but argument 2 has type 'int'

Make __page_to_pfn() return unsigned long.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/asm-generic/memory_model.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2620-rc6.orig/include/asm-generic/memory_model.h
+++ linux-2620-rc6/include/asm-generic/memory_model.h
@@ -54,7 +54,7 @@
 #define __page_to_pfn(pg)					\
 ({	struct page *__pg = (pg);				\
 	int __sec = page_to_section(__pg);			\
-	__pg - __section_mem_map_addr(__nr_to_section(__sec));	\
+	(unsigned long)(__pg - __section_mem_map_addr(__nr_to_section(__sec)));	\
 })
 
 #define __pfn_to_page(pfn)				\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
