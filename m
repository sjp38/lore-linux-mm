Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id C662B6B0062
	for <linux-mm@kvack.org>; Sat, 22 Sep 2012 06:33:47 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ro12so10081941pbb.14
        for <linux-mm@kvack.org>; Sat, 22 Sep 2012 03:33:47 -0700 (PDT)
From: raghu.prabhu13@gmail.com
Subject: [PATCH 3/5] Remove file_ra_state from arguments of count_history_pages.
Date: Sat, 22 Sep 2012 16:03:12 +0530
Message-Id: <e7275bef84867156b343ea3d558c4f669d1bc8b9.1348309711.git.rprabhu@wnohang.net>
In-Reply-To: <cover.1348290849.git.rprabhu@wnohang.net>
References: <cover.1348290849.git.rprabhu@wnohang.net>
In-Reply-To: <cover.1348309711.git.rprabhu@wnohang.net>
References: <cover.1348309711.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: fengguang.wu@intel.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

From: Raghavendra D Prabhu <rprabhu@wnohang.net>

count_history_pages doesn't require readahead state to calculate the offset from history.

Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
---
 mm/readahead.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index fec726c..3977455 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -349,7 +349,6 @@ static unsigned long get_next_ra_size(struct file_ra_state *ra,
  * 	- thrashing threshold in memory tight systems
  */
 static pgoff_t count_history_pages(struct address_space *mapping,
-				   struct file_ra_state *ra,
 				   pgoff_t offset, unsigned long max)
 {
 	pgoff_t head;
@@ -372,7 +371,7 @@ static int try_context_readahead(struct address_space *mapping,
 {
 	pgoff_t size;
 
-	size = count_history_pages(mapping, ra, offset, max);
+	size = count_history_pages(mapping, offset, max);
 
 	/*
 	 * no history pages:
-- 
1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
