Message-Id: <20050528231722.025759000@nd47.coderock.org>
Date: Sun, 29 May 2005 01:17:22 +0200
From: domen@coderock.org
Subject: [patch 2/2] printk : arch/i386/mm/ioremap.c
Content-Disposition: inline; filename=printk-arch_i386_mm_ioremap
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
 ioremap.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: quilt/arch/i386/mm/ioremap.c
===================================================================
--- quilt.orig/arch/i386/mm/ioremap.c
+++ quilt/arch/i386/mm/ioremap.c
@@ -241,7 +241,7 @@ void iounmap(volatile void __iomem *addr
 	write_lock(&vmlist_lock);
 	p = __remove_vm_area((void *) (PAGE_MASK & (unsigned long __force) addr));
 	if (!p) { 
-		printk("iounmap: bad address %p\n", addr);
+		printk(KERN_WARNING "iounmap: bad address %p\n", addr);
 		goto out_unlock;
 	}
 

--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
