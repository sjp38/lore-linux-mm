Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id A72796B0312
	for <linux-mm@kvack.org>; Tue,  8 May 2018 21:34:27 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u127so25415690qka.9
        for <linux-mm@kvack.org>; Tue, 08 May 2018 18:34:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w35-v6sor16426601qtb.73.2018.05.08.18.34.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 18:34:26 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 07/10] block: Add missing flush_dcache_page() call
Date: Tue,  8 May 2018 21:33:55 -0400
Message-Id: <20180509013358.16399-8-kent.overstreet@gmail.com>
In-Reply-To: <20180509013358.16399-1-kent.overstreet@gmail.com>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
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
