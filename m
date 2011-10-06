Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CF9306B0257
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 00:41:45 -0400 (EDT)
Received: by ywe9 with SMTP id 9so2984925ywe.14
        for <linux-mm@kvack.org>; Wed, 05 Oct 2011 21:41:44 -0700 (PDT)
From: Il Han <corone.il.han@gmail.com>
Subject: [PATCH] swapfile.c: Initialize a variable.
Date: Thu,  6 Oct 2011 13:41:14 +0900
Message-Id: <1317876074-25417-1-git-send-email-corone.il.han@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Il Han <corone.il.han@gmail.com>

Initialize the variable to remove the following warning.

mm/swapfile.c:2028: warning: 'span' may be used uninitialized in this function

Initialize it.

Signed-off-by: Il Han <corone.il.han@gmail.com>
---
 mm/swapfile.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 17bc224..d5ca685 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2016,7 +2016,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	int error;
 	union swap_header *swap_header;
 	int nr_extents;
-	sector_t span;
+	sector_t span = 0;
 	unsigned long maxpages;
 	unsigned char *swap_map = NULL;
 	struct page *page = NULL;
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
