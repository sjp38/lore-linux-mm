Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 043CA6B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 11:41:25 -0400 (EDT)
Date: Thu, 2 Aug 2012 10:41:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [08/16] Move duping of slab name to slab_common.c
In-Reply-To: <20120801211200.096404657@linux.com>
Message-ID: <alpine.DEB.2.00.1208021040330.23049@router.home>
References: <20120801211130.025389154@linux.com> <20120801211200.096404657@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

There is a superfluous freeing of the slab name still in slub. Slab name
freeing is handled by slab_common after this patch therefore this has to
be dropped.


Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-02 10:20:38.987659870 -0500
+++ linux-2.6/mm/slub.c	2012-08-02 10:20:47.943820713 -0500
@@ -5188,7 +5188,6 @@
 {
 	struct kmem_cache *s = to_slab(kobj);

-	kfree(s->name);
 	kmem_cache_free(kmem_cache, s);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
