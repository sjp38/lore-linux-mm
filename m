Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 8D5376B0070
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 03:14:58 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] Fix build error due to bio_endio_batch
Date: Wed,  9 Jan 2013 17:14:55 +0900
Message-Id: <1357719296-10562-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Kent Overstreet <koverstreet@google.com>

This patch fixes build error of recent mmotm.

Cc: Kent Overstreet <koverstreet@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
I don't know who already fix it.

 include/linux/bio.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index ad62bdb..5f5491767 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -69,6 +69,8 @@
 #define bio_segments(bio)	((bio)->bi_vcnt - (bio)->bi_idx)
 #define bio_sectors(bio)	((bio)->bi_size >> 9)
 
+void bio_endio_batch(struct bio *bio, int error, struct batch_complete *batch);
+
 static inline unsigned int bio_cur_bytes(struct bio *bio)
 {
 	if (bio->bi_vcnt)
@@ -542,8 +544,6 @@ static inline struct bio *bio_list_get(struct bio_list *bl)
 	return bio;
 }
 
-void bio_endio_batch(struct bio *bio, int error, struct batch_complete *batch);
-
 static inline void batch_complete_init(struct batch_complete *batch)
 {
 	bio_list_init(&batch->bio);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
