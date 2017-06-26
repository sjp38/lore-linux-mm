Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7116B0338
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:14:14 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id g2so8144939qta.14
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:14:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b189si5770486qkd.383.2017.06.26.05.14.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:14:13 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 09/51] block: comment on bio_iov_iter_get_pages()
Date: Mon, 26 Jun 2017 20:09:52 +0800
Message-Id: <20170626121034.3051-10-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

bio_iov_iter_get_pages() used unused bvec spaces for
storing page pointer array temporarily, and this patch
comments on this usage wrt. multipage bvec support.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/block/bio.c b/block/bio.c
index a5db117e8dfa..bf7f25889f6e 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -870,6 +870,10 @@ EXPORT_SYMBOL(bio_add_page);
  *
  * Pins as many pages from *iter and appends them to @bio's bvec array. The
  * pages will have to be released using put_page() when done.
+ *
+ * The hacking way of using bvec table as page pointer array is safe
+ * even after multipage bvec is introduced because that space can be
+ * thought as unused by bio_add_page().
  */
 int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter)
 {
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
