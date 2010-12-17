Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8E02B6B009E
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 12:14:06 -0500 (EST)
Received: by mail-px0-f177.google.com with SMTP id 7so196433pxi.8
        for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:14:05 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 3/5] tlbfs: Remove unnecessary page release
Date: Sat, 18 Dec 2010 02:13:38 +0900
Message-Id: <08549e97645f7d6c2bcc5c760a24fde56dfed513.1292604745.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1292604745.git.minchan.kim@gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1292604745.git.minchan.kim@gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, William Irwin <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

This patch series changes remove_from_page_cache's page ref counting
rule. page cache ref count is decreased in remove_from_page_cache.
So we don't need call again in caller context.

Cc: William Irwin <wli@holomorphy.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 fs/hugetlbfs/inode.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 9885082..4f32fb6 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -333,7 +333,6 @@ static void truncate_huge_page(struct page *page)
 	cancel_dirty_page(page, /* No IO accounting for huge pages? */0);
 	ClearPageUptodate(page);
 	remove_from_page_cache(page);
-	put_page(page);
 }
 
 static void truncate_hugepages(struct inode *inode, loff_t lstart)
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
