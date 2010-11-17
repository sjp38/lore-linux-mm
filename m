Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACB68D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 22:41:27 -0500 (EST)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id oAH3fOqJ031571
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 19:41:24 -0800
Received: from yxm8 (yxm8.prod.google.com [10.190.4.8])
	by hpaq6.eem.corp.google.com with ESMTP id oAH3fIbW027947
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 19:41:23 -0800
Received: by yxm8 with SMTP id 8so1001295yxm.35
        for <linux-mm@kvack.org>; Tue, 16 Nov 2010 19:41:18 -0800 (PST)
Date: Tue, 16 Nov 2010 19:41:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/3] mm: remove unused get_vm_area_node
Message-ID: <alpine.DEB.2.00.1011161935500.19230@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

get_vm_area_node() is unused in the kernel and can thus be removed.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/vmalloc.h |    3 ---
 mm/vmalloc.c            |    7 -------
 2 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -92,9 +92,6 @@ extern struct vm_struct *__get_vm_area_caller(unsigned long size,
 					unsigned long flags,
 					unsigned long start, unsigned long end,
 					void *caller);
-extern struct vm_struct *get_vm_area_node(unsigned long size,
-					  unsigned long flags, int node,
-					  gfp_t gfp_mask);
 extern struct vm_struct *remove_vm_area(const void *addr);
 
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1309,13 +1309,6 @@ struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
 						-1, GFP_KERNEL, caller);
 }
 
-struct vm_struct *get_vm_area_node(unsigned long size, unsigned long flags,
-				   int node, gfp_t gfp_mask)
-{
-	return __get_vm_area_node(size, 1, flags, VMALLOC_START, VMALLOC_END,
-				  node, gfp_mask, __builtin_return_address(0));
-}
-
 static struct vm_struct *find_vm_area(const void *addr)
 {
 	struct vmap_area *va;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
