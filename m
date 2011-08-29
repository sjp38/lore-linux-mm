Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 36293900138
	for <linux-mm@kvack.org>; Sun, 28 Aug 2011 23:49:54 -0400 (EDT)
Received: by pzk6 with SMTP id 6so12018382pzk.36
        for <linux-mm@kvack.org>; Sun, 28 Aug 2011 20:49:52 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 3/6] bounce: convert to __bio_endio() for bounced bio's
Date: Mon, 29 Aug 2011 12:47:37 +0900
Message-Id: <1314589660-2918-4-git-send-email-namhyung@gmail.com>
In-Reply-To: <1314589660-2918-1-git-send-email-namhyung@gmail.com>
References: <1314589660-2918-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Use untraced __bio_endio() for nested bio handling path to
suppress duplicated trace event.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
Cc: linux-mm@kvack.org
---
 mm/bounce.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/bounce.c b/mm/bounce.c
index 1481de68184b..c21289571d4d 100644
--- a/mm/bounce.c
+++ b/mm/bounce.c
@@ -142,7 +142,7 @@ static void bounce_end_io(struct bio *bio, mempool_t *pool, int err)
 		mempool_free(bvec->bv_page, pool);
 	}
 
-	bio_endio(bio_orig, err);
+	__bio_endio(bio_orig, err);
 	bio_put(bio);
 }
 
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
