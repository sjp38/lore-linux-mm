Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E50D6B02FD
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:13:00 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 50so18338446qtz.3
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:13:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n21si10917714qki.183.2017.06.26.05.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:12:59 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 05/51] fs/buffer: comment on direct access to bvec table
Date: Mon, 26 Jun 2017 20:09:48 +0800
Message-Id: <20170626121034.3051-6-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/buffer.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 4d5d03b42e11..1910f539770b 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3052,8 +3052,13 @@ static void end_bio_bh_io_sync(struct bio *bio)
 void guard_bio_eod(int op, struct bio *bio)
 {
 	sector_t maxsector;
-	struct bio_vec *bvec = &bio->bi_io_vec[bio->bi_vcnt - 1];
 	unsigned truncated_bytes;
+	/*
+	 * It is safe to truncate the last bvec in the following way
+	 * even though multipage bvec is supported, but we need to
+	 * fix the parameters passed to zero_user().
+	 */
+	struct bio_vec *bvec = &bio->bi_io_vec[bio->bi_vcnt - 1];
 
 	maxsector = i_size_read(bio->bi_bdev->bd_inode) >> 9;
 	if (!maxsector)
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
