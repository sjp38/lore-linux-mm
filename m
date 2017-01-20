Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A61816B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 09:30:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id z128so98822805pfb.4
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 06:30:35 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id f6si7017253plm.125.2017.01.20.06.30.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jan 2017 06:30:34 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id 19so5583986pfo.3
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 06:30:34 -0800 (PST)
From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] truncate: use i_blocksize()
Date: Fri, 20 Jan 2017 22:29:54 +0800
Message-Id: <9c8b2cd83c8f5653805d43debde9fa8817e02fc4.1484895804.git.geliangtang@gmail.com>
In-Reply-To: <0a58b38c7ddfbbc8f56cb8d815114bd4357a6016.1484895399.git.geliangtang@gmail.com>
References: <0a58b38c7ddfbbc8f56cb8d815114bd4357a6016.1484895399.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since i_blocksize() helper has been defined in fs.h, use it instead
of open-coding.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 mm/truncate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index dd7b24e..4c49a9b 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -785,7 +785,7 @@ EXPORT_SYMBOL(truncate_setsize);
  */
 void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
 {
-	int bsize = 1 << inode->i_blkbits;
+	int bsize = i_blocksize(inode);
 	loff_t rounded_from;
 	struct page *page;
 	pgoff_t index;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
