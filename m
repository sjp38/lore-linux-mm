Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17uRQl-0002lo-00
	for <linux-mm@kvack.org>; Wed, 25 Sep 2002 22:43:19 -0700
Date: Wed, 25 Sep 2002 22:43:19 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [11/13] use __GFP_NOKILL in do_generic_file_read()
Message-ID: <20020926054319.GR22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

do_generic_file_read() may be failed instead of killing innocent tasks.


diff -urN linux-2.5.33/mm/filemap.c linux-2.5.33-mm5/mm/filemap.c
--- linux-2.5.33/mm/filemap.c	2002-09-04 04:02:00.000000000 -0700
+++ linux-2.5.33-mm5/mm/filemap.c	2002-09-08 20:04:53.000000000 -0700
@@ -699,7 +699,7 @@
 		 * page..
 		 */
 		if (!cached_page) {
-			cached_page = page_cache_alloc(mapping);
+			cached_page = alloc_page(mapping->gfp_mask | __GFP_NOKILL);
 			if (!cached_page) {
 				desc->error = -ENOMEM;
 				break;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
