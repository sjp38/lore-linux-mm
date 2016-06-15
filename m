Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CAF36B025E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 02:53:18 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id b13so17327228pat.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 23:53:18 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id xr1si6230634pab.95.2016.06.14.23.53.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 23:53:16 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id ts6so901857pac.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 23:53:16 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH] mm/compaction: remove unnecessary order check in try_to_compact_pages()
Date: Wed, 15 Jun 2016 14:52:48 +0800
Message-Id: <1465973568-3496-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mhocko@suse.com, mina86@mina86.com, minchan@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

The caller __alloc_pages_direct_compact() already check (order == 0).
So no need to check again.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index fbb7b38..500acda 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1687,7 +1687,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 	*contended = COMPACT_CONTENDED_NONE;
 
 	/* Check if the GFP flags allow compaction */
-	if (!order || !may_enter_fs || !may_perform_io)
+	if (!may_enter_fs || !may_perform_io)
 		return COMPACT_SKIPPED;
 
 	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, mode);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
