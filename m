Received: from alogconduit1ah.ccr.net (root@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA12395
	for <linux-mm@kvack.org>; Sun, 23 May 1999 15:27:26 -0400
Subject: [PATCH] tweak page_address
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 23 May 1999 13:43:20 -0500
Message-ID: <m1aeuvsk3b.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Replace a multiplication by a shift in page_address.
The compiler probably already does but why take chances.

Eric

diff -uNrX linux-ignore-files linux-2.3.3.eb2/include/linux/pagemap.h linux-2.3.3.eb3/include/linux/pagemap.h
--- linux-2.3.3.eb2/include/linux/pagemap.h	Sun May 16 21:55:28 1999
+++ linux-2.3.3.eb3/include/linux/pagemap.h	Tue May 18 01:13:39 1999
@@ -14,7 +14,7 @@
 
 static inline unsigned long page_address(struct page * page)
 {
-	return PAGE_OFFSET + PAGE_SIZE * (page - mem_map);
+	return PAGE_OFFSET + ((page - mem_map) << PAGE_SHIFT);
 }
 
 /*
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
