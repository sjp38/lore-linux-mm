Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id CF8256B0264
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:10:51 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fe3so33345420pab.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:10:51 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id hq1si4402059pac.56.2016.03.30.00.10.38
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 00:10:39 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 07/16] zsmalloc: remove page_mapcount_reset
Date: Wed, 30 Mar 2016 16:12:06 +0900
Message-Id: <1459321935-3655-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1459321935-3655-1-git-send-email-minchan@kernel.org>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

We don't use page->_mapcount any more so no need to reset.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 4dd72a803568..0f6cce9b9119 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -922,7 +922,6 @@ static void reset_page(struct page *page)
 	set_page_private(page, 0);
 	page->mapping = NULL;
 	page->freelist = NULL;
-	page_mapcount_reset(page);
 }
 
 static void free_zspage(struct page *first_page)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
