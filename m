Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C79F46B03AF
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:17:03 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o3so12501239qto.15
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:17:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g8si11376846qti.358.2017.06.26.05.17.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:17:03 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 25/51] block: blk-merge: remove unnecessary check
Date: Mon, 26 Jun 2017 20:10:08 +0800
Message-Id: <20170626121034.3051-26-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
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
index bf7a0fa0199f..c6fcc49b9aea 100644
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
