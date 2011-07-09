Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DC6826B0083
	for <linux-mm@kvack.org>; Sat,  9 Jul 2011 15:42:05 -0400 (EDT)
Received: by mail-pw0-f41.google.com with SMTP id 12so2263896pwi.14
        for <linux-mm@kvack.org>; Sat, 09 Jul 2011 12:42:04 -0700 (PDT)
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: [PATCH 2/3] mm/readahead: Remove file_ra_state from arguments of count_history_pages.
Date: Sun, 10 Jul 2011 01:11:19 +0530
Message-Id: <a224acf18cff069f65e7e7eb10261e7dcfbb094f.1310239575.git.rprabhu@wnohang.net>
In-Reply-To: <cover.1310239575.git.rprabhu@wnohang.net>
References: <cover.1310239575.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

count_history_pages doesn't require readahead state to calculate the offset from history.

Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
---
 mm/readahead.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 867f9dd..925d3b3 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -343,7 +343,6 @@ static unsigned long get_next_ra_size(struct file_ra_state *ra,
  * 	- thrashing threshold in memory tight systems
  */
 static pgoff_t count_history_pages(struct address_space *mapping,
-				   struct file_ra_state *ra,
 				   pgoff_t offset, unsigned long max)
 {
 	pgoff_t head;
@@ -366,7 +365,7 @@ static int try_context_readahead(struct address_space *mapping,
 {
 	pgoff_t size;
 
-	size = count_history_pages(mapping, ra, offset, max);
+	size = count_history_pages(mapping, offset, max);
 
 	/*
 	 * no history pages:
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
