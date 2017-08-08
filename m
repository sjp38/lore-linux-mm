Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0776B04CD
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:54:31 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id x77so12804343qka.15
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:54:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w69si845169qkw.192.2017.08.08.01.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:54:30 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 45/49] fs: crypto: convert to bio_for_each_segment_all_sp()
Date: Tue,  8 Aug 2017 16:45:44 +0800
Message-Id: <20170808084548.18963-46-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/crypto/bio.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 6181e9526860..d5516ed19166 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -36,8 +36,9 @@ static void completion_pages(struct work_struct *work)
 	struct bio *bio = ctx->r.bio;
 	struct bio_vec *bv;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_segment_all_sp(bv, bio, i, bia) {
 		struct page *page = bv->bv_page;
 		int ret = fscrypt_decrypt_page(page->mapping->host, page,
 				PAGE_SIZE, 0, page->index);
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
