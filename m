Date: Wed, 23 Aug 2000 14:38:41 -0300
From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: vmalloc issuing BUG() on get_vm_area failure
Message-ID: <20000823143841.A18492@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

	 Using our random failing kmalloc debug patch I've noticed that vmalloc
calls BUG() when get_vm_area fails (one of the possible reasons is for kmalloc
to fail on get_vm_area, which is possible), should it do it? or is it a
debugging leftover? if it is a leftover bellow is a patch to get rid of it.

- Arnaldo

--- linux-2.4.0-test7-pre7/mm/vmalloc.c	Tue Aug  8 01:01:36 2000
+++ linux-2.4.0-test7-pre7.acme/mm/vmalloc.c	Wed Aug 23 14:31:08 2000
@@ -222,10 +222,8 @@
 		return NULL;
 	}
 	area = get_vm_area(size, VM_ALLOC);
-	if (!area) {
-		BUG();
+	if (!area)
 		return NULL;
-	}
 	addr = area->addr;
 	if (vmalloc_area_pages(VMALLOC_VMADDR(addr), size, gfp_mask, prot)) {
 		vfree(addr);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
