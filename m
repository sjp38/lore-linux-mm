Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4CA36B0313
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:13:42 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id d78so30365116qkb.0
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:13:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n9si11575071qkh.270.2017.06.26.05.13.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:13:40 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 06/51] f2fs: f2fs_read_end_io: comment on direct access to bvec table
Date: Mon, 26 Jun 2017 20:09:49 +0800
Message-Id: <20170626121034.3051-7-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Chao Yu <yuchao0@huawei.com>
Cc: linux-f2fs-devel@lists.sourceforge.net
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/f2fs/data.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 7697d03e8a98..622c44a1be78 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -56,6 +56,10 @@ static void f2fs_read_end_io(struct bio *bio)
 	int i;
 
 #ifdef CONFIG_F2FS_FAULT_INJECTION
+	/*
+	 * It is still safe to retrieve the 1st page of the bio
+	 * in this way after supporting multipage bvec.
+	 */
 	if (time_to_inject(F2FS_P_SB(bio->bi_io_vec->bv_page), FAULT_IO)) {
 		f2fs_show_injection_info(FAULT_IO);
 		bio->bi_status = BLK_STS_IOERR;
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
