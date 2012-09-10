Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 3A00B6B0071
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 09:14:32 -0400 (EDT)
Date: Mon, 10 Sep 2012 21:14:26 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH] idr: Rename MAX_LEVEL to MAX_ID_LEVEL
Message-ID: <20120910131426.GA12431@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, kernel-janitors@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

To avoid name conflicts:

drivers/video/riva/fbdev.c:281:9: sparse: preprocessor token MAX_LEVEL redefined

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---

Andrew: the conflict happens in Glauber's kmemcg-slab tree.  So it's
better to quickly push this pre-fix to upstream before Glauber's patches.


 include/linux/idr.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux.orig/include/linux/idr.h	2012-09-10 21:08:51.177452944 +0800
+++ linux/include/linux/idr.h	2012-09-10 21:08:57.729452732 +0800
@@ -43,10 +43,10 @@
 #define MAX_ID_MASK (MAX_ID_BIT - 1)
 
 /* Leave the possibility of an incomplete final layer */
-#define MAX_LEVEL (MAX_ID_SHIFT + IDR_BITS - 1) / IDR_BITS
+#define MAX_ID_LEVEL (MAX_ID_SHIFT + IDR_BITS - 1) / IDR_BITS
 
 /* Number of id_layer structs to leave in free list */
-#define IDR_FREE_MAX MAX_LEVEL + MAX_LEVEL
+#define IDR_FREE_MAX MAX_ID_LEVEL + MAX_ID_LEVEL
 
 struct idr_layer {
 	unsigned long		 bitmap; /* A zero bit means "space here" */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
