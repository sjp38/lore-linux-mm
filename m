Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 74FFB6B02C3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:46:48 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id e2so12506768qta.13
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:46:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 5si762017qke.453.2017.08.08.01.46.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:46:47 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 03/49] kernel/power/swap.c: comment on direct access to bvec table
Date: Tue,  8 Aug 2017 16:45:02 +0800
Message-Id: <20170808084548.18963-4-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-pm@vger.kernel.org

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: linux-pm@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 kernel/power/swap.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/power/swap.c b/kernel/power/swap.c
index 57d22571f306..aa52ccc03fcc 100644
--- a/kernel/power/swap.c
+++ b/kernel/power/swap.c
@@ -238,6 +238,8 @@ static void hib_init_batch(struct hib_bio_batch *hb)
 static void hib_end_io(struct bio *bio)
 {
 	struct hib_bio_batch *hb = bio->bi_private;
+
+	/* single page bio, safe for multipage bvec */
 	struct page *page = bio->bi_io_vec[0].bv_page;
 
 	if (bio->bi_status) {
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
