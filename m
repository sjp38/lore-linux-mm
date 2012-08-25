Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 027946B0044
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 10:12:29 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ro12so5540475pbb.14
        for <linux-mm@kvack.org>; Sat, 25 Aug 2012 07:12:29 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/2] slab: fix starting index for finding another object
Date: Sat, 25 Aug 2012 23:11:11 +0900
Message-Id: <1345903871-1921-2-git-send-email-js1304@gmail.com>
In-Reply-To: <1345903871-1921-1-git-send-email-js1304@gmail.com>
References: <Yes>
 <1345903871-1921-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux-foundation.org>

In array cache, there is a object at index 0.
So fix it.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Christoph Lameter <cl@linux-foundation.org>

diff --git a/mm/slab.c b/mm/slab.c
index 45cf59a..eb74bf5 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -976,7 +976,7 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		}
 
 		/* The caller cannot use PFMEMALLOC objects, find another one */
-		for (i = 1; i < ac->avail; i++) {
+		for (i = 0; i < ac->avail; i++) {
 			/* If a !PFMEMALLOC object is found, swap them */
 			if (!is_obj_pfmemalloc(ac->entry[i])) {
 				objp = ac->entry[i];
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
