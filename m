Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 371A06B0311
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:47:38 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id k126so12957873qke.8
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:47:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v25si780847qtf.254.2017.08.08.01.47.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:47:37 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 08/49] block: comment on bio_alloc_pages()
Date: Tue,  8 Aug 2017 16:45:07 +0800
Message-Id: <20170808084548.18963-9-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

This patch adds comment on usage of bio_alloc_pages().

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/block/bio.c b/block/bio.c
index e241bbc49f14..826b5d173416 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -981,7 +981,9 @@ EXPORT_SYMBOL(bio_advance);
  * @bio: bio to allocate pages for
  * @gfp_mask: flags for allocation
  *
- * Allocates pages up to @bio->bi_vcnt.
+ * Allocates pages up to @bio->bi_vcnt, and this function should only
+ * be called on a new initialized bio, which means all pages aren't added
+ * to the bio via bio_add_page() yet.
  *
  * Returns 0 on success, -ENOMEM on failure. On failure, any allocated pages are
  * freed.
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
