Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 08C026B000C
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 11:39:54 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b2so316625pgt.6
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 08:39:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b9si409531pgn.191.2018.04.09.08.39.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 08:39:53 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 7/7] block: use GFP_KERNEL for allocations from blk_get_request
Date: Mon,  9 Apr 2018 17:39:16 +0200
Message-Id: <20180409153916.23901-8-hch@lst.de>
In-Reply-To: <20180409153916.23901-1-hch@lst.de>
References: <20180409153916.23901-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

blk_get_request is used for pass-through style I/O and thus doesn't need
GFP_NOIO.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 block/blk-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 432923751551..253a869558f9 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1578,7 +1578,7 @@ static struct request *blk_old_get_request(struct request_queue *q,
 				unsigned int op, blk_mq_req_flags_t flags)
 {
 	struct request *rq;
-	gfp_t gfp_mask = flags & BLK_MQ_REQ_NOWAIT ? GFP_ATOMIC : GFP_NOIO;
+	gfp_t gfp_mask = flags & BLK_MQ_REQ_NOWAIT ? GFP_ATOMIC : GFP_KERNEL;
 	int ret = 0;
 
 	WARN_ON_ONCE(q->mq_ops);
-- 
2.16.3
