Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3043B6B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 02:21:20 -0400 (EDT)
Received: by pzk34 with SMTP id 34so4280716pzk.11
        for <linux-mm@kvack.org>; Mon, 19 Oct 2009 23:21:15 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] rmap : simplify the code for try_to_unmap_file
Date: Tue, 20 Oct 2009 14:21:10 +0800
Message-Id: <1256019670-23293-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

Just simplify the code when the mlocked is true.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/rmap.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index dd43373..c57c3b6 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1100,13 +1100,10 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 		if (ret == SWAP_MLOCK) {
 			mlocked = try_to_mlock_page(page, vma);
 			if (mlocked)
-				break;  /* stop if actually mlocked page */
+				goto out;  /* stop if actually mlocked page */
 		}
 	}
 
-	if (mlocked)
-		goto out;
-
 	if (list_empty(&mapping->i_mmap_nonlinear))
 		goto out;
 
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
