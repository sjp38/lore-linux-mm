Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id EE3A5440441
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 20:29:08 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id r129so48763770wmr.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 17:29:08 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id a8si1746685wmi.35.2016.02.05.17.29.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 17:29:07 -0800 (PST)
Subject: [PATCH] mm: fix filemap.c kernel-doc warning
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <56B54C5E.5010208@infradead.org>
Date: Fri, 5 Feb 2016 17:29:02 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

From: Randy Dunlap <rdunlap@infradead.org>

Add missing kernel-doc notation for function parameter 'gfp_mask' to
fix kernel-doc warning.

..//mm/filemap.c:1898: warning: No description found for parameter 'gfp_mask'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 mm/filemap.c |    1 +
 1 file changed, 1 insertion(+)

--- lnx-45-rc2.orig/mm/filemap.c
+++ lnx-45-rc2/mm/filemap.c
@@ -1890,6 +1890,7 @@ EXPORT_SYMBOL(generic_file_read_iter);
  * page_cache_read - adds requested page to the page cache if not already there
  * @file:	file to read
  * @offset:	page index
+ * @gfp_mask:	memory allocation flags
  *
  * This adds the requested page to the page cache if it isn't already there,
  * and schedules an I/O to read in its contents from disk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
