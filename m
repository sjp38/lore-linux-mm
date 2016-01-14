Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 66F91828E2
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:24:30 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id e65so93814714pfe.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:30 -0800 (PST)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id 83si6898944pfs.84.2016.01.13.21.24.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:24:29 -0800 (PST)
Received: by mail-pa0-x241.google.com with SMTP id gi1so35229227pac.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:29 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 01/16] mm/slab: fix stale code comment
Date: Thu, 14 Jan 2016 14:24:14 +0900
Message-Id: <1452749069-15334-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We use freelist_idx_t type for free object management whose size
would be smaller than size of unsigned int. Fix it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 6ecc697..c8f9c3a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -537,7 +537,7 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 	 * on it. For the latter case, the memory allocated for a
 	 * slab is used for:
 	 *
-	 * - One unsigned int for each object
+	 * - One freelist_idx_t for each object
 	 * - Padding to respect alignment of @align
 	 * - @buffer_size bytes for each object
 	 *
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
