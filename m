Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8759F6B0005
	for <linux-mm@kvack.org>; Sun, 11 Mar 2018 08:25:39 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u129-v6so1425860lff.9
        for <linux-mm@kvack.org>; Sun, 11 Mar 2018 05:25:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e26sor948921ljf.79.2018.03.11.05.25.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Mar 2018 05:25:37 -0700 (PDT)
From: Roman Lakeev <sunnyddayss@gmail.com>
Subject: [PATCH] mm/slab.c: remove duplicated check of colour_next
Date: Sun, 11 Mar 2018 15:25:34 +0300
Message-ID: <87bmfulry9.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Roman Lakeev <sunnyddayss@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Date: Sun, 11 Mar 2018 11:05:29 +0300
Signed-off-by: Roman Lakeev <sunnyddayss@gmail.com>
remove check that offset greater than cachep->colour
bacause this is already checked in previous lines

---
 mm/slab.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 324446621b3e..6a48f122bd82 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2674,11 +2674,7 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 	if (n->colour_next >= cachep->colour)
 		n->colour_next = 0;
 
-	offset = n->colour_next;
-	if (offset >= cachep->colour)
-		offset = 0;
-
-	offset *= cachep->colour_off;
+	offset = n->colour_next * cachep->colour_off;
 
 	/* Get slab management. */
 	freelist = alloc_slabmgmt(cachep, page, offset,
-- 
2.16.2
