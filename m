Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17uRQH-0002kW-00
	for <linux-mm@kvack.org>; Wed, 25 Sep 2002 22:42:49 -0700
Date: Wed, 25 Sep 2002 22:42:49 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [6/13] use __GFP_NOKILL in select_bits_alloc()
Message-ID: <20020926054249.GM22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

select_bits_alloc() is done in select.c, triggering the OOM killer.
The system calls doing so are failable, and so use __GFP_NOKILL.


diff -urN linux-2.5.33/fs/select.c linux-2.5.33-mm5/fs/select.c
--- linux-2.5.33/fs/select.c	2002-08-31 15:04:47.000000000 -0700
+++ linux-2.5.33-mm5/fs/select.c	2002-09-08 22:00:56.000000000 -0700
@@ -237,7 +237,7 @@
 
 static void *select_bits_alloc(int size)
 {
-	return kmalloc(6 * size, GFP_KERNEL);
+	return kmalloc(6 * size, GFP_KERNEL | __GFP_NOKILL);
 }
 
 static void select_bits_free(void *bits, int size)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
