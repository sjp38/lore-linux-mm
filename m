Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D95C68E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 12:51:07 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q21-v6so3032521pff.21
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 09:51:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r75-v6sor3358359pfd.125.2018.09.19.09.51.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 09:51:06 -0700 (PDT)
From: "haiqing.shq" <leviathan0992@gmail.com>
Subject: [PATCH] mm/filemap.c: Use existing variable
Date: Wed, 19 Sep 2018 16:50:55 +0000
Message-Id: <1537375855-2088-1-git-send-email-leviathan0992@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: jack@suse.cz, mgorman@techsingularity.net, ak@linux.intel.com, yang.s@alibaba-inc.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "haiqing.shq" <leviathan0992@gmail.com>

From: "haiqing.shq" <leviathan0992@gmail.com>

Use the variable write_len instead of ov_iter_count(from).

Signed-off-by: haiqing.shq <leviathan0992@gmail.com>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 52517f2..4a699ef 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -3012,7 +3012,7 @@ int pagecache_write_end(struct file *file, struct address_space *mapping,
 	if (iocb->ki_flags & IOCB_NOWAIT) {
 		/* If there are pages to writeback, return */
 		if (filemap_range_has_page(inode->i_mapping, pos,
-					   pos + iov_iter_count(from)))
+					   pos + write_len))
 			return -EAGAIN;
 	} else {
 		written = filemap_write_and_wait_range(mapping, pos,
-- 
1.8.3.1
