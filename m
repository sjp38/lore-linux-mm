Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D71B6B0260
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 10:58:53 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 5so819675380pgi.2
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 07:58:53 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id r197si46763745pfr.213.2016.12.27.07.58.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 07:58:52 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id i88so18310386pfk.2
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 07:58:52 -0800 (PST)
From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH v1 04/54] mm: page_io.c: comment on direct access to bvec table
Date: Tue, 27 Dec 2016 23:55:53 +0800
Message-Id: <1482854250-13481-5-git-send-email-tom.leiming@gmail.com>
In-Reply-To: <1482854250-13481-1-git-send-email-tom.leiming@gmail.com>
References: <1482854250-13481-1-git-send-email-tom.leiming@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org
Cc: linux-block@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Ming Lei <tom.leiming@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Christie <mchristi@redhat.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Joe Perches <joe@perches.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 mm/page_io.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_io.c b/mm/page_io.c
index 23f6d0d3470f..368a16aa810c 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -43,6 +43,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
 
 void end_swap_bio_write(struct bio *bio)
 {
+	/* single page bio, safe for multipage bvec */
 	struct page *page = bio->bi_io_vec[0].bv_page;
 
 	if (bio->bi_error) {
@@ -116,6 +117,7 @@ static void swap_slot_free_notify(struct page *page)
 
 static void end_swap_bio_read(struct bio *bio)
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
