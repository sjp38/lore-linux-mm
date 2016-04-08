Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 408796B007E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 01:18:45 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id fe3so68301390pab.1
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 22:18:45 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id ah8si4206904pad.148.2016.04.07.22.18.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Apr 2016 22:18:44 -0700 (PDT)
Received: from epcpsbgm1new.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0O5A02OJQUR6SRC0@mailout2.samsung.com> for linux-mm@kvack.org;
 Fri, 08 Apr 2016 14:18:42 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH] mm fix commmets: If SPARSEMEM, pgdata doesn't have page_ext
Date: Fri, 08 Apr 2016 13:17:42 +0800
Message-id: <"000001d19156$1e02a5c0$5a07f140$@yang"@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 'Weijie Yang' <weijie.yang.kh@gmail.com>

If SPARSEMEM, use page_ext in mem_section
if !SPARSEMEM, use page_ext in pgdata

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 include/linux/mmzone.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c60df92..43c412c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1056,7 +1056,7 @@ struct mem_section {
 	unsigned long *pageblock_flags;
 #ifdef CONFIG_PAGE_EXTENSION
 	/*
-	 * If !SPARSEMEM, pgdat doesn't have page_ext pointer. We use
+	 * If SPARSEMEM, pgdat doesn't have page_ext pointer. We use
 	 * section. (see page_ext.h about this.)
 	 */
 	struct page_ext *page_ext;
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
