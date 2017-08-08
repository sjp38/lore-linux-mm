Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 586456B02F3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:46:58 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id g13so12687554qta.0
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:46:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v62si764551qkc.104.2017.08.08.01.46.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:46:57 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 04/49] mm: page_io.c: comment on direct access to bvec table
Date: Tue,  8 Aug 2017 16:45:03 +0800
Message-Id: <20170808084548.18963-5-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 mm/page_io.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_io.c b/mm/page_io.c
index b6c4ac388209..11c6f4a9a25b 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -43,6 +43,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
 
 void end_swap_bio_write(struct bio *bio)
 {
+	/* single page bio, safe for multipage bvec */
 	struct page *page = bio->bi_io_vec[0].bv_page;
 
 	if (bio->bi_status) {
@@ -116,6 +117,7 @@ static void swap_slot_free_notify(struct page *page)
 
 static void end_swap_bio_read(struct bio *bio)
 {
+	/* single page bio, safe for multipage bvec */
 	struct page *page = bio->bi_io_vec[0].bv_page;
 	struct task_struct *waiter = bio->bi_private;
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
