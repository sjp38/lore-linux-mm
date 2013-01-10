Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 8132B6B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 14:00:56 -0500 (EST)
Message-Id: <0000013c25d6168a-9f389916-826e-42b3-9bbd-e19297ac7f9f-000000@email.amazonses.com>
Date: Thu, 10 Jan 2013 19:00:53 +0000
From: Christoph Lameter <cl@linux.com>
Subject: REN2 [01/13] slab_common: Use proper formatting specs for unsigned size_t
References: <20130110190027.780479755@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-12-19 15:04:38.952850252 -0600
+++ linux/mm/slab_common.c	2012-12-20 10:38:35.878002392 -0600
@@ -299,7 +299,7 @@ void __init create_boot_cache(struct kme
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
