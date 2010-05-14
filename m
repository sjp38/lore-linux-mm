Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 148AF6B01F2
	for <linux-mm@kvack.org>; Fri, 14 May 2010 14:43:07 -0400 (EDT)
Message-Id: <20100514183943.354637558@quilx.com>
References: <20100514183908.118952419@quilx.com>
Date: Fri, 14 May 2010 13:39:10 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC SLEB 02/10] SLUB: Constants need UL
Content-Disposition: inline; filename=slub_constant_ul
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

UL suffix is missing in some constants. Conform to how slab.h uses constants.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-04-27 12:39:36.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-04-27 12:41:05.000000000 -0500
@@ -170,8 +170,8 @@
 #define MAX_OBJS_PER_PAGE	65535 /* since page.objects is u16 */
 
 /* Internal SLUB flags */
-#define __OBJECT_POISON		0x80000000 /* Poison object */
-#define __SYSFS_ADD_DEFERRED	0x40000000 /* Not yet visible via sysfs */
+#define __OBJECT_POISON		0x80000000UL /* Poison object */
+#define __SYSFS_ADD_DEFERRED	0x40000000UL /* Not yet visible via sysfs */
 
 static int kmem_size = sizeof(struct kmem_cache);
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
