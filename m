Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0761A660024
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:30 -0400 (EDT)
Message-Id: <20100804024526.143898224@linux.com>
Date: Tue, 03 Aug 2010 21:45:18 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 04/23] SLUB: Constants need UL
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=slub_constant_ul
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

UL suffix is missing in some constants. Conform to how slab.h uses constants.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |   20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-06 14:53:16.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-07-06 15:08:24.000000000 -0500
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
