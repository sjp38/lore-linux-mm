Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 81E686B00A1
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 12:14:19 -0500 (EST)
Received: by mail-pv0-f169.google.com with SMTP id 30so143145pvc.14
        for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:14:15 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 5/5] truncate: Remove unnecessary page release
Date: Sat, 18 Dec 2010 02:13:40 +0900
Message-Id: <02ab98b3a1450f7a1c31edc48ccc57e887cee900.1292604746.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1292604745.git.minchan.kim@gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1292604745.git.minchan.kim@gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Nick Piggin <npiggin@suse.de>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

This patch series changes remove_from_page_cache's page ref counting
rule. page cache ref count is decreased in remove_from_page_cache.
So we don't need call again in caller context.

Cc: Nick Piggin <npiggin@suse.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/truncate.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 9ee5673..8decb93 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -114,7 +114,6 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 	 * calls cleancache_put_page (and note page->mapping is now NULL)
 	 */
 	cleancache_flush_page(mapping, page);
-	page_cache_release(page);	/* pagecache ref */
 	return 0;
 }
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
