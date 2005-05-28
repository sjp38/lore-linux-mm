Message-Id: <20050528231720.901977000@nd47.coderock.org>
Date: Sun, 29 May 2005 01:17:21 +0200
From: domen@coderock.org
Subject: [patch 1/2] printk : arch/i386/mm/pgtable.c
Content-Disposition: inline; filename=printk-arch_i386_mm_pgtable
Sender: owner-linux-mm@kvack.org
From: Christophe Lucas <clucas@rotomalug.org>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christophe Lucas <clucas@rotomalug.org>, domen@coderock.org
List-ID: <linux-mm.kvack.org>



printk() calls should include appropriate KERN_* constant.

Signed-off-by: Christophe Lucas <clucas@rotomalug.org>
Signed-off-by: Domen Puncer <domen@coderock.org>


---
 pgtable.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

Index: quilt/arch/i386/mm/pgtable.c
===================================================================
--- quilt.orig/arch/i386/mm/pgtable.c
+++ quilt/arch/i386/mm/pgtable.c
@@ -31,9 +31,9 @@ void show_mem(void)
 	pg_data_t *pgdat;
 	unsigned long i;
 
-	printk("Mem-info:\n");
+	printk(KERN_INFO "Mem-info:\n");
 	show_free_areas();
-	printk("Free swap:       %6ldkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
+	printk(KERN_INFO "Free swap:       %6ldkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
 	for_each_pgdat(pgdat) {
 		for (i = 0; i < pgdat->node_spanned_pages; ++i) {
 			page = pgdat->node_mem_map + i;
@@ -48,11 +48,11 @@ void show_mem(void)
 				shared += page_count(page) - 1;
 		}
 	}
-	printk("%d pages of RAM\n", total);
-	printk("%d pages of HIGHMEM\n",highmem);
-	printk("%d reserved pages\n",reserved);
-	printk("%d pages shared\n",shared);
-	printk("%d pages swap cached\n",cached);
+	printk(KERN_INFO "%d pages of RAM\n", total);
+	printk(KERN_INFO "%d pages of HIGHMEM\n",highmem);
+	printk(KERN_INFO "%d reserved pages\n",reserved);
+	printk(KERN_INFO "%d pages shared\n",shared);
+	printk(KERN_INFO "%d pages swap cached\n",cached);
 }
 
 /*
@@ -105,16 +105,16 @@ void set_pmd_pfn(unsigned long vaddr, un
 	pmd_t *pmd;
 
 	if (vaddr & (PMD_SIZE-1)) {		/* vaddr is misaligned */
-		printk ("set_pmd_pfn: vaddr misaligned\n");
+		printk(KERN_WARNING "set_pmd_pfn: vaddr misaligned\n");
 		return; /* BUG(); */
 	}
 	if (pfn & (PTRS_PER_PTE-1)) {		/* pfn is misaligned */
-		printk ("set_pmd_pfn: pfn misaligned\n");
+		printk(KERN_WARNING "set_pmd_pfn: pfn misaligned\n");
 		return; /* BUG(); */
 	}
 	pgd = swapper_pg_dir + pgd_index(vaddr);
 	if (pgd_none(*pgd)) {
-		printk ("set_pmd_pfn: pgd_none\n");
+		printk(KERN_WARNING "set_pmd_pfn: pgd_none\n");
 		return; /* BUG(); */
 	}
 	pud = pud_offset(pgd, vaddr);

--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
