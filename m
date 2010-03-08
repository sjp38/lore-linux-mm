Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5FD316B0098
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 04:34:08 -0500 (EST)
Received: by pwj9 with SMTP id 9so3231686pwj.14
        for <linux-mm@kvack.org>; Mon, 08 Mar 2010 01:34:06 -0800 (PST)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] shmem : remove redundant code
Date: Mon,  8 Mar 2010 17:33:02 +0800
Message-Id: <1268040782-28561-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

The  prep_new_page() will call set_page_private(page, 0) to initiate
the page.

So the code is redundant.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/shmem.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index eef4ebe..dde4363 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -433,8 +433,6 @@ static swp_entry_t *shmem_swp_alloc(struct shmem_inode_info *info, unsigned long
 
 		spin_unlock(&info->lock);
 		page = shmem_dir_alloc(mapping_gfp_mask(inode->i_mapping));
-		if (page)
-			set_page_private(page, 0);
 		spin_lock(&info->lock);
 
 		if (!page) {
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
