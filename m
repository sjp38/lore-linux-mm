Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED5816B0290
	for <linux-mm@kvack.org>; Sat, 29 Oct 2016 04:13:15 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fl2so58221293pad.7
        for <linux-mm@kvack.org>; Sat, 29 Oct 2016 01:13:15 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id e13si16695642pgn.145.2016.10.29.01.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Oct 2016 01:13:15 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id s8so3378949pfj.2
        for <linux-mm@kvack.org>; Sat, 29 Oct 2016 01:13:15 -0700 (PDT)
From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 18/60] mm: page_io.c: comment on direct access to bvec table
Date: Sat, 29 Oct 2016 16:08:17 +0800
Message-Id: <1477728600-12938-19-git-send-email-tom.leiming@gmail.com>
In-Reply-To: <1477728600-12938-1-git-send-email-tom.leiming@gmail.com>
References: <1477728600-12938-1-git-send-email-tom.leiming@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org
Cc: linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ming Lei <tom.leiming@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Mike Christie <mchristi@redhat.com>, Santosh Shilimkar <santosh.shilimkar@oracle.com>, Joe Perches <joe@perches.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 mm/page_io.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_io.c b/mm/page_io.c
index a2651f58c86a..b0c0069ec1f4 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -43,6 +43,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
 
 void end_swap_bio_write(struct bio *bio)
 {
+	/* single page bio, safe for multipage bvec */
 	struct page *page = bio->bi_io_vec[0].bv_page;
 
 	if (bio->bi_error) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
