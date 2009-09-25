Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EC6456B00AC
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 05:12:37 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id c37so854049anc.26
        for <linux-mm@kvack.org>; Fri, 25 Sep 2009 02:12:41 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] swap : remove unused field of swapper_space
Date: Fri, 25 Sep 2009 17:12:33 +0800
Message-Id: <1253869953-4747-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

There is no place to use the i_mmap_nonlinear of swapper_space, so
remove it.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/swap_state.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 6d1daeb..be16a6b 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -43,7 +43,6 @@ struct address_space swapper_space = {
 	.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
 	.tree_lock	= __SPIN_LOCK_UNLOCKED(swapper_space.tree_lock),
 	.a_ops		= &swap_aops,
-	.i_mmap_nonlinear = LIST_HEAD_INIT(swapper_space.i_mmap_nonlinear),
 	.backing_dev_info = &swap_backing_dev_info,
 };
 
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
