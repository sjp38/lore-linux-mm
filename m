Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17uRQb-0002lK-00
	for <linux-mm@kvack.org>; Wed, 25 Sep 2002 22:43:09 -0700
Date: Wed, 25 Sep 2002 22:43:09 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [9/13] use __GFP_NOKILL in page_cache_read()
Message-ID: <20020926054309.GP22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

page_cache_read() may be failed instead of killing innocent tasks.


diff -urN linux-2.5.33/mm/filemap.c linux-2.5.33-mm5/mm/filemap.c
--- linux-2.5.33/mm/filemap.c	2002-09-04 04:02:00.000000000 -0700
+++ linux-2.5.33-mm5/mm/filemap.c	2002-09-08 20:04:53.000000000 -0700
@@ -256,7 +256,7 @@
 	struct page *page; 
 	int error;
 
-	page = page_cache_alloc(mapping);
+	page = alloc_page(mapping->gfp_mask | __GFP_NOKILL);
 	if (!page)
 		return -ENOMEM;
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
