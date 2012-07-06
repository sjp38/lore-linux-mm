Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 8E1286B0074
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 15:42:36 -0400 (EDT)
Date: Fri, 6 Jul 2012 14:42:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm, slab: Build fix for recent kmem_cache changes
In-Reply-To: <alpine.LFD.2.02.1207021342230.1916@tux.localdomain>
Message-ID: <alpine.DEB.2.00.1207061442040.31733@router.home>
References: <20120622174249.GB4144@avionic-0098.adnet.avionic-design.de> <alpine.LFD.2.02.1207021342230.1916@tux.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Thierry Reding <thierry.reding@avionic-design.de>, linux-mm@kvack.org

And here is another fix:

Subject: slob: Undo slob hunk

Commit fd3142a59af2012a7c5dc72ec97a4935ff1c5fc6 broke
slob since a piece of a change for a later patch slipped into
it.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slob.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-07-06 08:38:18.851205889 -0500
+++ linux-2.6/mm/slob.c	2012-07-06 08:38:47.259205237 -0500
@@ -516,7 +516,7 @@ struct kmem_cache *kmem_cache_create(con

 	if (c) {
 		c->name = name;
-		c->size = c->object_size;
+		c->size = size;
 		if (flags & SLAB_DESTROY_BY_RCU) {
 			/* leave room for rcu footer at the end of object */
 			c->size += sizeof(struct slob_rcu);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
