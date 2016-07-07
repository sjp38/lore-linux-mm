Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E181828E2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:06:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so24091438pfa.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:06:51 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id q70si838963pfa.49.2016.07.07.02.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 02:06:50 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id t190so1283324pfb.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:06:49 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v4 7/8] mm/zsmalloc: use helper to clear page->flags bit
Date: Thu,  7 Jul 2016 17:05:37 +0800
Message-Id: <1467882338-4300-7-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467882338-4300-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467882338-4300-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, mingo@redhat.com, rostedt@goodmis.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

user ClearPagePrivate/ClearPagePrivate2 helper to clear
PG_private/PG_private_2 in page->flags

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
----
v4: none
v3: none
v2: none
---
 mm/zsmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 780eabd..163bc90 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -940,8 +940,8 @@ static void unpin_tag(unsigned long handle)
 static void reset_page(struct page *page)
 {
 	__ClearPageMovable(page);
-	clear_bit(PG_private, &page->flags);
-	clear_bit(PG_private_2, &page->flags);
+	ClearPagePrivate(page);
+	ClearPagePrivate2(page);
 	set_page_private(page, 0);
 	page_mapcount_reset(page);
 	ClearPageHugeObject(page);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
