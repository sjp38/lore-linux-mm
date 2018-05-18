Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C39C6B0593
	for <linux-mm@kvack.org>; Fri, 18 May 2018 03:50:21 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w201-v6so672770qkb.16
        for <linux-mm@kvack.org>; Fri, 18 May 2018 00:50:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m17-v6sor5252250qvo.111.2018.05.18.00.50.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 00:50:20 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 09/10] block: Export bio check/set pages_dirty
Date: Fri, 18 May 2018 03:49:15 -0400
Message-Id: <20180518074918.13816-18-kent.overstreet@gmail.com>
In-Reply-To: <20180518074918.13816-1-kent.overstreet@gmail.com>
References: <20180518074918.13816-1-kent.overstreet@gmail.com>
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
