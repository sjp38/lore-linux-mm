Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51398828F2
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 02:42:32 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ao6so189852008pac.2
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 23:42:32 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id f6si2613346pfb.109.2016.06.30.23.42.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 23:42:31 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id i123so9305045pfg.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 23:42:31 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH 8/8] mm/zsmalloc: use helper to clear page->flags bit
Date: Fri,  1 Jul 2016 14:41:06 +0800
Message-Id: <1467355266-9735-8-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

user ClearPagePrivate/ClearPagePrivate2 helper to clear
PG_private/PG_private_2 in page->flags

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
 mm/zsmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 1c7460b..356db9a 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -945,8 +945,8 @@ static void unpin_tag(unsigned long handle)
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
