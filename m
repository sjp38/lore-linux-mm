Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6F66B0316
	for <linux-mm@kvack.org>; Tue,  8 May 2018 21:34:31 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id d128so25174836qkf.18
        for <linux-mm@kvack.org>; Tue, 08 May 2018 18:34:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y23sor2762246qkj.27.2018.05.08.18.34.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 18:34:30 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 09/10] block: Export bio check/set pages_dirty
Date: Tue,  8 May 2018 21:33:57 -0400
Message-Id: <20180509013358.16399-10-kent.overstreet@gmail.com>
In-Reply-To: <20180509013358.16399-1-kent.overstreet@gmail.com>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>

Signed-off-by: Kent Overstreet <kent.overstreet@gmail.com>
---
 block/bio.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/block/bio.c b/block/bio.c
index 5c81391100..6689102f5d 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1610,6 +1610,7 @@ void bio_set_pages_dirty(struct bio *bio)
 			set_page_dirty_lock(page);
 	}
 }
+EXPORT_SYMBOL_GPL(bio_set_pages_dirty);
 
 static void bio_release_pages(struct bio *bio)
 {
@@ -1693,6 +1694,7 @@ void bio_check_pages_dirty(struct bio *bio)
 		bio_put(bio);
 	}
 }
+EXPORT_SYMBOL_GPL(bio_check_pages_dirty);
 
 void generic_start_io_acct(struct request_queue *q, int rw,
 			   unsigned long sectors, struct hd_struct *part)
-- 
2.17.0
