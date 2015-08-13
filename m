Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5FD6B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:01:40 -0400 (EDT)
Received: by pdbfa8 with SMTP id fa8so12423157pdb.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 17:01:40 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id bw2si623840pbb.162.2015.08.12.17.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 17:01:39 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so12437998pdr.2
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 17:01:39 -0700 (PDT)
From: Gregory Fong <gregory.0xf0@gmail.com>
Subject: [PATCH] mm: cma: mark cma_bitmap_maxno() inline in header
Date: Wed, 12 Aug 2015 17:01:21 -0700
Message-Id: <1439424082-12356-1-git-send-email-gregory.0xf0@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Gregory Fong <gregory.0xf0@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, open list <linux-kernel@vger.kernel.org>

cma_bitmap_maxno() was marked as static and not static inline, which
can cause warnings about this function not being used if this file is
included in a file that does not call that function, and violates the
conventions used elsewhere.  The two options are to move the function
implementation back to mm/cma.c or make it inline here, and it's
simple enough for the latter to make sense.

Signed-off-by: Gregory Fong <gregory.0xf0@gmail.com>
---
 mm/cma.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/cma.h b/mm/cma.h
index 1132d73..17c75a4 100644
--- a/mm/cma.h
+++ b/mm/cma.h
@@ -16,7 +16,7 @@ struct cma {
 extern struct cma cma_areas[MAX_CMA_AREAS];
 extern unsigned cma_area_count;
 
-static unsigned long cma_bitmap_maxno(struct cma *cma)
+static inline unsigned long cma_bitmap_maxno(struct cma *cma)
 {
 	return cma->count >> cma->order_per_bit;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
