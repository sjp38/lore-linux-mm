Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A6E296B0397
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:15:40 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z22so47549415qka.4
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:15:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z31si11383024qtg.278.2017.06.26.05.15.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:15:39 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 17/51] bvec_iter: introduce BVEC_ITER_ALL_INIT
Date: Mon, 26 Jun 2017 20:10:00 +0800
Message-Id: <20170626121034.3051-18-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

Introduce BVEC_ITER_ALL_INIT for iterating one bio
from start to end.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bvec.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 89b65b82d98f..162ca7caf510 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -94,4 +94,13 @@ static inline void bvec_iter_advance(const struct bio_vec *bv,
 		((bvl = bvec_iter_bvec((bio_vec), (iter))), 1);	\
 	     bvec_iter_advance((bio_vec), &(iter), (bvl).bv_len))
 
+/* for iterating one bio from start to end */
+#define BVEC_ITER_ALL_INIT (struct bvec_iter)				\
+{									\
+	.bi_sector	= 0,						\
+	.bi_size	= UINT_MAX,					\
+	.bi_idx		= 0,						\
+	.bi_bvec_done	= 0,						\
+}
+
 #endif /* __LINUX_BVEC_ITER_H */
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
