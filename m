Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6F1B66B024D
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 15:07:16 -0400 (EDT)
Date: Tue, 15 Jun 2010 14:04:00 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: slub: Constants need UL
Message-ID: <alpine.DEB.2.00.1006151403070.10865@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Subject: SLUB: Constants need UL

UL suffix is missing in some constants. Conform to how slab.h uses constants.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-05-24 14:40:33.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-05-24 14:42:46.000000000 -0500
@@ -162,8 +162,8 @@
 #define MAX_OBJS_PER_PAGE	65535 /* since page.objects is u16 */

 /* Internal SLUB flags */
-#define __OBJECT_POISON		0x80000000 /* Poison object */
-#define __SYSFS_ADD_DEFERRED	0x40000000 /* Not yet visible via sysfs */
+#define __OBJECT_POISON		0x80000000UL /* Poison object */
+#define __SYSFS_ADD_DEFERRED	0x40000000UL /* Not yet visible via sysfs */

 static int kmem_size = sizeof(struct kmem_cache);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
