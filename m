Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 356066B026D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:46:47 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id i7-v6so1884118qtp.4
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:46:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w1-v6si3823288qvf.185.2018.06.27.05.46.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 05:46:46 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V7 04/24] block: remove bio_clone_kmalloc
Date: Wed, 27 Jun 2018 20:45:28 +0800
Message-Id: <20180627124548.3456-5-ming.lei@redhat.com>
In-Reply-To: <20180627124548.3456-1-ming.lei@redhat.com>
References: <20180627124548.3456-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Christoph Hellwig <hch@lst.de>

From: Christoph Hellwig <hch@lst.de>

Unused now.

Reviewed-by: Ming Lei <ming.lei@redhat.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/bio.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index f08f5fe7bd08..430807f9f44b 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -443,12 +443,6 @@ static inline struct bio *bio_kmalloc(gfp_t gfp_mask, unsigned int nr_iovecs)
 	return bio_alloc_bioset(gfp_mask, nr_iovecs, NULL);
 }
 
-static inline struct bio *bio_clone_kmalloc(struct bio *bio, gfp_t gfp_mask)
-{
-	return bio_clone_bioset(bio, gfp_mask, NULL);
-
-}
-
 extern blk_qc_t submit_bio(struct bio *);
 
 extern void bio_endio(struct bio *);
-- 
2.9.5
