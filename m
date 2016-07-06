Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF459828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 02:26:50 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id he1so435202401pac.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:26:50 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id m28si2490586pfj.13.2016.07.05.23.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 23:26:50 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id ib6so4221541pad.3
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:26:50 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v3 7/8] mm/zsmalloc: use helper to clear page->flags bit
Date: Wed,  6 Jul 2016 14:23:52 +0800
Message-Id: <1467786233-4481-7-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467786233-4481-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467786233-4481-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

user ClearPagePrivate/ClearPagePrivate2 helper to clear
PG_private/PG_private_2 in page->flags

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
----
v3: none
v2: none
---
 mm/zsmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 46526b9..17d3f53 100644
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
