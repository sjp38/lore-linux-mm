Message-ID: <48FFC21B.3000808@oracle.com>
Date: Wed, 22 Oct 2008 17:15:23 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: [PATCH] mm: fix kernel-doc function notation
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Delete excess kernel-doc notation in mm/ subdirectory.
Actually this is a kernel-doc notation fix.

Warning(/var/linsrc/linux-2.6.27-git10//mm/vmalloc.c:902): Excess function parameter or struct member 'returns' description in 'vm_map_ram'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/vmalloc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-2.6.27-git10.orig/mm/vmalloc.c
+++ linux-2.6.27-git10/mm/vmalloc.c
@@ -896,7 +896,8 @@ EXPORT_SYMBOL(vm_unmap_ram);
  * @count: number of pages
  * @node: prefer to allocate data structures on this node
  * @prot: memory protection to use. PAGE_KERNEL for regular RAM
- * @returns: a pointer to the address that has been mapped, or NULL on failure
+ *
+ * Returns: a pointer to the address that has been mapped, or %NULL on failure
  */
 void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t prot)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
