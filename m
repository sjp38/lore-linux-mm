Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id D838B6B005C
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 04:44:22 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so528332pbc.15
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 01:44:22 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 11/15] slab: remove SLAB_LIMIT
Date: Wed, 16 Oct 2013 17:44:08 +0900
Message-Id: <1381913052-23875-12-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

It's useless now, so remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 6ced1cc..c271d5b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -163,8 +163,6 @@
  */
 static bool pfmemalloc_active __read_mostly;
 
-#define	SLAB_LIMIT	(((unsigned int)(~0U))-1)
-
 /*
  * struct slab
  *
@@ -626,8 +624,6 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 		mgmt_size = 0;
 		nr_objs = slab_size / buffer_size;
 
-		if (nr_objs > SLAB_LIMIT)
-			nr_objs = SLAB_LIMIT;
 	} else {
 		/*
 		 * Ignore padding for the initial guess. The padding
@@ -648,9 +644,6 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 		       > slab_size)
 			nr_objs--;
 
-		if (nr_objs > SLAB_LIMIT)
-			nr_objs = SLAB_LIMIT;
-
 		mgmt_size = slab_mgmt_size(nr_objs, align);
 	}
 	*num = nr_objs;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
