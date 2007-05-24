From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 24 May 2007 14:13:34 +1000
Subject: [PATCH 2/2] Make map_vm_area() static
Message-Id: <20070524041337.D2FA7DDE06@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>
List-ID: <linux-mm.kvack.org>

map_vm_area() is only ever used inside of mm/vmalloc.c. This makes
it static and removes the prototype.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

---

 include/linux/vmalloc.h |    2 --
 mm/vmalloc.c            |    3 ++-
 2 files changed, 2 insertions(+), 3 deletions(-)

Index: linux-cell/include/linux/vmalloc.h
===================================================================
--- linux-cell.orig/include/linux/vmalloc.h	2007-05-24 13:42:22.000000000 +1000
+++ linux-cell/include/linux/vmalloc.h	2007-05-24 13:52:08.000000000 +1000
@@ -66,8 +66,6 @@ extern struct vm_struct *get_vm_area_nod
 					  gfp_t gfp_mask);
 extern struct vm_struct *remove_vm_area(void *addr);
 
-extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
-			struct page ***pages);
 extern void unmap_kernel_range(unsigned long addr, unsigned long size);
 
 /*
Index: linux-cell/mm/vmalloc.c
===================================================================
--- linux-cell.orig/mm/vmalloc.c	2007-05-24 13:44:28.000000000 +1000
+++ linux-cell/mm/vmalloc.c	2007-05-24 13:52:08.000000000 +1000
@@ -145,7 +145,8 @@ static inline int vmap_pud_range(pgd_t *
 	return 0;
 }
 
-int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
+static int map_vm_area(struct vm_struct *area, pgprot_t prot,
+		       struct page ***pages)
 {
 	pgd_t *pgd;
 	unsigned long next;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
