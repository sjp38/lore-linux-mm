Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17uRQg-0002la-00
	for <linux-mm@kvack.org>; Wed, 25 Sep 2002 22:43:14 -0700
Date: Wed, 25 Sep 2002 22:43:14 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [10/13] use __GFP_NOKILL in find_or_create_page()
Message-ID: <20020926054314.GQ22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

find_or_create_page() may be failed instead of killing innocent tasks.


diff -urN linux-2.5.33/mm/filemap.c linux-2.5.33-mm5/mm/filemap.c
--- linux-2.5.33/mm/filemap.c	2002-09-04 04:02:00.000000000 -0700
+++ linux-2.5.33-mm5/mm/filemap.c	2002-09-08 20:04:53.000000000 -0700
@@ -472,7 +472,7 @@
 	page = find_lock_page(mapping, index);
 	if (!page) {
 		if (!cached_page) {
-			cached_page = alloc_page(gfp_mask);
+			cached_page = alloc_page(gfp_mask | __GFP_NOKILL);
 			if (!cached_page)
 				return NULL;
 		}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
