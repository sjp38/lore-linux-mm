Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 19FB56B005C
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:44:24 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 12/16] slab: remove SLAB_LIMIT
Date: Thu, 22 Aug 2013 17:44:21 +0900
Message-Id: <1377161065-30552-13-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

It's useless now, so remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 7216ebe..98257e4 100644
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
