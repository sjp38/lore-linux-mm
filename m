Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 499816B00A1
	for <linux-mm@kvack.org>; Mon,  4 May 2009 10:37:01 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.14.3/8.13.8) with ESMTP id n44EbXOd200524
	for <linux-mm@kvack.org>; Mon, 4 May 2009 14:37:33 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n44EbWQf3805428
	for <linux-mm@kvack.org>; Mon, 4 May 2009 16:37:32 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n44EbWOt000371
	for <linux-mm@kvack.org>; Mon, 4 May 2009 16:37:32 +0200
Date: Mon, 4 May 2009 16:37:31 +0200
From: Ralph Wuerthner <ralphw@linux.vnet.ibm.com>
Subject: [PATCH] alloc_vmap_area: fix memory leak
Message-ID: <20090504163731.3675ea87@rwuerthntp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

[PATCH] alloc_vmap_area: fix memory leak

From: Ralph Wuerthner <ralphw@linux.vnet.ibm.com>

If alloc_vmap_area() fails the allocated struct vmap_area has to be
freed.

Signed-off-by: Ralph Wuerthner <ralphw@linux.vnet.ibm.com>

---
 mm/vmalloc.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -402,6 +402,7 @@ overflow:
 			printk(KERN_WARNING
 				"vmap allocation for size %lu failed: "
 				"use vmalloc=<size> to increase size.\n", size);
+		kfree(va);
 		return ERR_PTR(-EBUSY);
 	}
 


-- 
Ralph Wuerthner

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
