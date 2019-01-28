Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id BADB18E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 07:27:46 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id a62so8866272oii.23
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 04:27:46 -0800 (PST)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id v68si4781561oif.156.2019.01.28.04.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 04:27:45 -0800 (PST)
From: zhengbin <zhengbin13@huawei.com>
Subject: [PATCH] mm/filemap: pass inclusive 'end_byte' parameter to filemap_range_has_page
Date: Mon, 28 Jan 2019 20:31:19 +0800
Message-ID: <1548678679-18122-1-git-send-email-zhengbin13@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, willy@infradead.org, darrick.wong@oracle.com, amir73il@gmail.com, david@fromorbit.com, hannes@cmpxchg.org, jrdr.linux@gmail.com, hughd@google.com, linux-mm@kvack.org
Cc: houtao1@huawei.com, yi.zhang@huawei.com, zhengbin13@huawei.com

The 'end_byte' parameter of filemap_range_has_page is required to be
inclusive, so follow the rule.

Signed-off-by: zhengbin <zhengbin13@huawei.com>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 9f5e323..a236bf3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -3081,7 +3081,7 @@ generic_file_direct_write(struct kiocb *iocb, struct iov_iter *from)
 	if (iocb->ki_flags & IOCB_NOWAIT) {
 		/* If there are pages to writeback, return */
 		if (filemap_range_has_page(inode->i_mapping, pos,
-					   pos + write_len))
+					   pos + write_len - 1))
 			return -EAGAIN;
 	} else {
 		written = filemap_write_and_wait_range(mapping, pos,
--
2.7.4
