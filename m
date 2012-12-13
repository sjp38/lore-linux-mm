Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 9F38E6B002B
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 16:15:35 -0500 (EST)
Message-Id: <0000013b961f55be-58b80fdd-8a8f-4638-9b9a-f7accded8df8-000000@email.amazonses.com>
Date: Thu, 13 Dec 2012 21:15:34 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Ren [01/12] slab_common: Use proper formatting specs for unsigned size_t
References: <20121213211413.134419945@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-12-12 14:53:33.000000000 -0600
+++ linux/mm/slab_common.c	2012-12-12 14:55:25.738939882 -0600
@@ -243,7 +243,7 @@ void __init create_boot_cache(struct kme
 	err = __kmem_cache_create(s, flags);
 
 	if (err)
-		panic("Creation of kmalloc slab %s size=%zd failed. Reason %d\n",
+		panic("Creation of kmalloc slab %s size=%zu failed. Reason %d\n",
 					name, size, err);
 
 	s->refcount = -1;	/* Exempt from merging for now */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
