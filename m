Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id E45D36B00EA
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 13:53:20 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id h18so4776739igc.0
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 10:53:19 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id l7si11437687icq.65.2014.04.14.10.53.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Apr 2014 10:53:17 -0700 (PDT)
Message-ID: <534C2086.2010704@infradead.org>
Date: Mon, 14 Apr 2014 10:53:10 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: [PATCH] mm: fix new kernel-doc warning in filemap.c
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix new kernel-doc warning in mm/filemap.c:

Warning(mm/filemap.c:2600): Excess function parameter 'ppos' description in '__generic_file_aio_write'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 mm/filemap.c |    1 -
 1 file changed, 1 deletion(-)

--- lnx-315-rc1.orig/mm/filemap.c
+++ lnx-315-rc1/mm/filemap.c
@@ -2581,7 +2581,6 @@ EXPORT_SYMBOL(generic_perform_write);
  * @iocb:	IO state structure (file, offset, etc.)
  * @iov:	vector with data to write
  * @nr_segs:	number of segments in the vector
- * @ppos:	position where to write
  *
  * This function does all the work needed for actually writing data to a
  * file. It does all basic checks, removes SUID from the file, updates

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
