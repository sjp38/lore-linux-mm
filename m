Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 65C696B0069
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 14:50:16 -0500 (EST)
Date: Mon, 14 Jan 2013 19:50:15 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: REN2 [09/13] Common function to create the kmalloc array
In-Reply-To: <alpine.DEB.2.02.1301140843010.27095@gentwo.org>
Message-ID: <0000013c3a9cb8c9-a078da66-8f45-4317-bfc3-5ae7fb069146-000000@email.amazonses.com>
References: <20130110190027.780479755@linux.com> <0000013c25e08975-f7fd7592-7d64-409c-874d-d00ea2106f2e-000000@email.amazonses.com> <20130111072355.GA2346@lge.com> <alpine.DEB.2.02.1301140843010.27095@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Mon, 14 Jan 2013, Christoph Lameter wrote:

> Subject: Fix: Always provide a name to create_boot_cache even during early boot.

Argh. Wrong variable. My kvm does not work right and I also have not been
able to fully test this one yet. But it builds fine.


Subject: Fix: Always provide a name to create_boot_cache even during early boot.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2013-01-14 12:43:41.581429175 -0600
+++ linux/mm/slab_common.c	2013-01-14 12:44:43.282380404 -0600
@@ -313,7 +313,7 @@ struct kmem_cache *__init create_kmalloc
 	if (!s)
 		panic("Out of memory when creating slab %s\n", name);

-	create_boot_cache(s, name, size, flags);
+	create_boot_cache(s, name ? name : "kmalloc", size, flags);
 	list_add(&s->list, &slab_caches);
 	s->refcount = 1;
 	return s;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
