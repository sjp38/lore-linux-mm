Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 345C76B0253
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 09:55:10 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id tz10so113028782pab.3
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 06:55:10 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id t9si15583332pac.180.2016.10.14.06.55.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Oct 2016 06:55:09 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] z3fold: remove the unnecessary limit in z3fold_compact_page
Date: Fri, 14 Oct 2016 21:35:25 +0800
Message-ID: <1476452125-22059-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vitalywool@gmail.com, david@fromorbit.com, sjenning@redhat.com, ddstreet@ieee.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zhong jiang <zhongjiang@huawei.com>

z3fold compact page has nothing with the last_chunks. even if
last_chunks is not free, compact page will proceed.

The patch just remove the limit without functional change.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/z3fold.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index e8fc216..4668e1c 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -258,8 +258,7 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
 
 
 	if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
-	    zhdr->middle_chunks != 0 &&
-	    zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
+	    zhdr->middle_chunks != 0 && zhdr->first_chunks == 0) {
 		memmove(beg + ZHDR_SIZE_ALIGNED,
 			beg + (zhdr->start_middle << CHUNK_SHIFT),
 			zhdr->middle_chunks << CHUNK_SHIFT);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
