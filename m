Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF5D56B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 11:22:05 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so1085970837pgc.1
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 08:22:05 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id b187si50481543pgc.0.2016.12.28.08.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Dec 2016 08:22:04 -0800 (PST)
Subject: [PATCH] mm: fix filemap.c kernel-doc warnings
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <a66fe492-518c-ad6c-5f03-5e8b721fb451@infradead.org>
Date: Wed, 28 Dec 2016 08:22:03 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix kernel-doc warnings in mm/filemap.c:

..//mm/filemap.c:993: warning: No description found for parameter '__page'
..//mm/filemap.c:993: warning: Excess function parameter 'page' description in '__lock_page'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 mm/filemap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-410-rc1.orig/mm/filemap.c
+++ lnx-410-rc1/mm/filemap.c
@@ -987,7 +987,7 @@ EXPORT_SYMBOL_GPL(page_endio);
 
 /**
  * __lock_page - get a lock on the page, assuming we need to sleep to get it
- * @page: the page to lock
+ * @__page: the page to lock
  */
 void __lock_page(struct page *__page)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
