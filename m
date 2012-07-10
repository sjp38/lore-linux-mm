Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 7D4396B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 19:31:08 -0400 (EDT)
Date: Tue, 10 Jul 2012 18:31:05 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: linux-next: Early crashed kernel on CONFIG_SLOB
In-Reply-To: <CF1C132D-2873-408A-BCC9-B9F57BE6EDDB@linuxfoundation.org>
Message-ID: <alpine.DEB.2.00.1207101830480.5988@router.home>
References: <20120710111756.GA11351@localhost> <CF1C132D-2873-408A-BCC9-B9F57BE6EDDB@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <christoph@linuxfoundation.org>
Cc: "wfg@linux.intel.com" <wfg@linux.intel.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Here is the patch:

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
