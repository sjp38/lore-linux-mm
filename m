Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCE66B0082
	for <linux-mm@kvack.org>; Sat,  9 Jul 2011 15:41:51 -0400 (EDT)
Received: by mail-pw0-f41.google.com with SMTP id 12so2263896pwi.14
        for <linux-mm@kvack.org>; Sat, 09 Jul 2011 12:41:50 -0700 (PDT)
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: [PATCH 1/3] mm/readahead: Change the check for PageReadahead into an else-if
Date: Sun, 10 Jul 2011 01:11:18 +0530
Message-Id: <5a2186efeb299af150b1bef10f1c3a428722b3de.1310239575.git.rprabhu@wnohang.net>
In-Reply-To: <cover.1310239575.git.rprabhu@wnohang.net>
References: <cover.1310239575.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

>From 51daa88ebd8e0d437289f589af29d4b39379ea76, page_sync_readahead coalesces
async readahead into its readahead window, so another checking for that again is
not required.

Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
---
 mm/filemap.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index a8251a8..074c23d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1115,8 +1115,7 @@ find_page:
 			page = find_get_page(mapping, index);
 			if (unlikely(page == NULL))
 				goto no_cached_page;
-		}
-		if (PageReadahead(page)) {
+		} else if (PageReadahead(page)) {
 			page_cache_async_readahead(mapping,
 					ra, filp, page,
 					index, last_index - index);
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
