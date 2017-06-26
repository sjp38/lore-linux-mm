Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2D686B0313
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:11:53 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id d78so30352277qkb.0
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:11:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a12si11385120qte.109.2017.06.26.05.11.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:11:52 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 02/51] block: loop: comment on direct access to bvec table
Date: Mon, 26 Jun 2017 20:09:45 +0800
Message-Id: <20170626121034.3051-3-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/block/loop.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 0de11444e317..88063ab17e9a 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -487,6 +487,11 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 	/* nomerge for loop request queue */
 	WARN_ON(cmd->rq->bio != cmd->rq->biotail);
 
+	/*
+	 * For multipage bvec support, it is safe to pass the bvec
+	 * table to iov iterator, because iov iter still uses bvec
+	 * iter helpers to travese bvec.
+	 */
 	bvec = __bvec_iter_bvec(bio->bi_io_vec, bio->bi_iter);
 	iov_iter_bvec(&iter, ITER_BVEC | rw, bvec,
 		      bio_segments(bio), blk_rq_bytes(cmd->rq));
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
