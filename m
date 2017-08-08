Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 543996B0492
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:48:53 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l13so12599772qtc.15
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:48:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j97si733898qte.527.2017.08.08.01.48.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:48:52 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 15/49] bvec_iter: introduce BVEC_ITER_ALL_INIT
Date: Tue,  8 Aug 2017 16:45:14 +0800
Message-Id: <20170808084548.18963-16-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
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
index ec8a4d7af6bd..fe7a22dd133b 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -125,4 +125,13 @@ static inline bool bvec_iter_rewind(const struct bio_vec *bv,
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
