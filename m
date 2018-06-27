Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id B74596B026F
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:46:59 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f8-v6so1757850qtj.22
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:46:59 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s127-v6si3876185qkf.131.2018.06.27.05.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 05:46:58 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V7 05/24] md: remove a bogus comment
Date: Wed, 27 Jun 2018 20:45:29 +0800
Message-Id: <20180627124548.3456-6-ming.lei@redhat.com>
In-Reply-To: <20180627124548.3456-1-ming.lei@redhat.com>
References: <20180627124548.3456-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Christoph Hellwig <hch@lst.de>

From: Christoph Hellwig <hch@lst.de>

The function name mentioned doesn't exist, and the code next to it
doesn't match the description either.

Reviewed-by: Ming Lei <ming.lei@redhat.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/md/md.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/md/md.c b/drivers/md/md.c
index 29b0cd9ec951..81f458514ac0 100644
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -204,10 +204,6 @@ static int start_readonly;
  */
 static bool create_on_open = true;
 
-/* bio_clone_mddev
- * like bio_clone_bioset, but with a local bio set
- */
-
 struct bio *bio_alloc_mddev(gfp_t gfp_mask, int nr_iovecs,
 			    struct mddev *mddev)
 {
-- 
2.9.5
