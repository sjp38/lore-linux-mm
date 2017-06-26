Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65DBC6B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:19:30 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u126so47731765qka.9
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:19:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p10si10856210qke.174.2017.06.26.05.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:19:29 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 38/51] dm-crypt: convert to bio_for_each_segment_all_sp()
Date: Mon, 26 Jun 2017 20:10:21 +0800
Message-Id: <20170626121034.3051-39-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Mike Snitzer <snitzer@redhat.com>

Cc: Mike Snitzer <snitzer@redhat.com>
Cc:dm-devel@redhat.com
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/md/dm-crypt.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index 664ba3504f48..0f2f44a73a32 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -1446,8 +1446,9 @@ static void crypt_free_buffer_pages(struct crypt_config *cc, struct bio *clone)
 {
 	unsigned int i;
 	struct bio_vec *bv;
+	struct bvec_iter_all bia;
 
-	bio_for_each_segment_all(bv, clone, i) {
+	bio_for_each_segment_all_sp(bv, clone, i, bia) {
 		BUG_ON(!bv->bv_page);
 		mempool_free(bv->bv_page, cc->page_pool);
 	}
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
