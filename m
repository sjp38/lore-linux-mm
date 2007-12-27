Message-Id: <20071227053401.203784468@sgi.com>
References: <20071227053246.902699851@sgi.com>
Date: Wed, 26 Dec 2007 21:32:53 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 07/18] Use page_cache_xxx in mm/migrate.c
Content-Disposition: inline; filename=0008-Use-page_cache_xxx-in-mm-migrate.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

- Only use mapping in remove_file_migration_ptes after it was checked
  for NULL.

Use page_cache_xxx in mm/migrate.c

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/migrate.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.24-rc6-mm1/mm/migrate.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/migrate.c	2007-12-26 20:14:13.726253698 -0800
+++ linux-2.6.24-rc6-mm1/mm/migrate.c	2007-12-26 20:20:50.804618309 -0800
@@ -197,11 +197,12 @@ static void remove_file_migration_ptes(s
 	struct vm_area_struct *vma;
 	struct address_space *mapping = page_mapping(new);
 	struct prio_tree_iter iter;
-	pgoff_t pgoff = new->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff;
 
 	if (!mapping)
 		return;
 
+	pgoff = new->index << mapping_order(mapping);
 	spin_lock(&mapping->i_mmap_lock);
 
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
