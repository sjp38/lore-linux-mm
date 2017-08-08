Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6555B6B04A2
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:50:46 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id w51so12625676qtc.12
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:50:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 41si882028qkr.388.2017.08.08.01.50.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:50:45 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 23/49] block: blk-merge: remove unnecessary check
Date: Tue,  8 Aug 2017 16:45:22 +0800
Message-Id: <20170808084548.18963-24-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

In this case, 'sectors' can't be zero at all, so remove the check
and let the bio be splitted.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/blk-merge.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/block/blk-merge.c b/block/blk-merge.c
index aeb8933e6cae..ac217fce4921 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -128,9 +128,7 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 				nsegs++;
 				sectors = max_sectors;
 			}
-			if (sectors)
-				goto split;
-			/* Make this single bvec as the 1st segment */
+			goto split;
 		}
 
 		if (bvprvp && blk_queue_cluster(q)) {
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
