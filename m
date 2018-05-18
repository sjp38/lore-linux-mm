Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37CBF6B0590
	for <linux-mm@kvack.org>; Fri, 18 May 2018 03:50:15 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id w26-v6so6093606qto.4
        for <linux-mm@kvack.org>; Fri, 18 May 2018 00:50:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 21-v6sor837492qkk.89.2018.05.18.00.50.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 00:50:14 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 07/10] block: Add missing flush_dcache_page() call
Date: Fri, 18 May 2018 03:49:12 -0400
Message-Id: <20180518074918.13816-15-kent.overstreet@gmail.com>
In-Reply-To: <20180518074918.13816-1-kent.overstreet@gmail.com>
References: <20180518074918.13816-1-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>

Since a bio can point to userspace pages (e.g. direct IO), this is
generally necessary.

Signed-off-by: Kent Overstreet <kent.overstreet@gmail.com>
---
 block/bio.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/block/bio.c b/block/bio.c
index c58544d4bc..ce8e259f9a 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -994,6 +994,8 @@ void bio_copy_data_iter(struct bio *dst, struct bvec_iter *dst_iter,
 		kunmap_atomic(dst_p);
 		kunmap_atomic(src_p);
 
+		flush_dcache_page(dst_bv.bv_page);
+
 		bio_advance_iter(src, src_iter, bytes);
 		bio_advance_iter(dst, dst_iter, bytes);
 	}
-- 
2.17.0
