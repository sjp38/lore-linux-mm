Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B2B536B0006
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 11:39:32 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f9-v6so7200098plo.17
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 08:39:32 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 22si379696pga.811.2018.04.09.08.39.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 08:39:31 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/7] block: fix __get_request documentation
Date: Mon,  9 Apr 2018 17:39:11 +0200
Message-Id: <20180409153916.23901-3-hch@lst.de>
In-Reply-To: <20180409153916.23901-1-hch@lst.de>
References: <20180409153916.23901-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 block/blk-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index abcb8684ba67..abde22c755ab 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1517,7 +1517,7 @@ static struct request *__get_request(struct request_list *rl, unsigned int op,
  * @bio: bio to allocate request for (can be %NULL)
  * @flags: BLK_MQ_REQ_* flags.
  *
- * Get a free request from @q.  If %__GFP_DIRECT_RECLAIM is set in @gfp_mask,
+ * Get a free request from @q.  If %BLK_MQ_REQ_NOWAIT is set in @flags,
  * this function keeps retrying under memory pressure and fails iff @q is dead.
  *
  * Must be called with @q->queue_lock held and,
-- 
2.16.3
