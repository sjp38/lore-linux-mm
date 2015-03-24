Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 18F5E6B0073
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 19:13:53 -0400 (EDT)
Received: by ieclw3 with SMTP id lw3so9961589iec.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 16:13:52 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id lp9si9954330igb.52.2015.03.24.16.13.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 16:13:52 -0700 (PDT)
Received: by igcau2 with SMTP id au2so86404494igc.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 16:13:52 -0700 (PDT)
Date: Tue, 24 Mar 2015 16:13:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, slab: correct config option in comment
Message-ID: <alpine.DEB.2.10.1503241612260.22087@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

CONFIG_SLAB_DEBUG doesn't exist, CONFIG_DEBUG_SLAB does.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/slab.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -18,7 +18,7 @@
 
 /*
  * Flags to pass to kmem_cache_create().
- * The ones marked DEBUG are only valid if CONFIG_SLAB_DEBUG is set.
+ * The ones marked DEBUG are only valid if CONFIG_DEBUG_SLAB is set.
  */
 #define SLAB_DEBUG_FREE		0x00000100UL	/* DEBUG: Perform (expensive) checks on free */
 #define SLAB_RED_ZONE		0x00000400UL	/* DEBUG: Red zone objs in a cache */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
