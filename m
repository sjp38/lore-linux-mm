Message-Id: <20071130173507.749913641@sgi.com>
References: <20071130173448.951783014@sgi.com>
Date: Fri, 30 Nov 2007 09:34:55 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 07/19] Use page_cache_xxx in mm/migrate.c
Content-Disposition: inline; filename=0008-Use-page_cache_xxx-in-mm-migrate.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in mm/migrate.c

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/migrate.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mm/mm/migrate.c
===================================================================
--- mm.orig/mm/migrate.c	2007-11-28 12:27:32.184464256 -0800
+++ mm/mm/migrate.c	2007-11-28 14:10:49.200977227 -0800
@@ -197,7 +197,7 @@ static void remove_file_migration_ptes(s
 	struct vm_area_struct *vma;
 	struct address_space *mapping = page_mapping(new);
 	struct prio_tree_iter iter;
-	pgoff_t pgoff = new->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff = new->index << mapping_order(mapping);
 
 	if (!mapping)
 		return;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
