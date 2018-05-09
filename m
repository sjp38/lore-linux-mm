Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 937916B038A
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:54:30 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b13-v6so19416141pgw.1
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:54:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id z7-v6si14234473pgv.614.2018.05.09.00.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:54:29 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/6] block: fix __get_request documentation
Date: Wed,  9 May 2018 09:54:04 +0200
Message-Id: <20180509075408.16388-3-hch@lst.de>
In-Reply-To: <20180509075408.16388-1-hch@lst.de>
References: <20180509075408.16388-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 block/blk-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 0573f9226c2d..52f2d4623ec7 100644
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
2.17.0
