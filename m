Received: from freak.mileniumnet.com.br (IDENT:maluco@freak.mileniumnet.com.br [200.199.222.9])
	by strauss.mileniumnet.com.br (8.9.3/8.9.3) with ESMTP id OAA12912
	for <linux-mm@kvack.org>; Wed, 16 May 2001 14:32:54 -0300
Date: Wed, 16 May 2001 13:22:44 -0400 (AMT)
From: Thiago Rondon <maluco@mileniumnet.com.br>
Subject: [PATCH] mm/swapfile.c
Message-ID: <Pine.LNX.4.21.0105161318470.6454-100000@freak.mileniumnet.com.br>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

when we do "goto bad_count", we dont need to do 
swap_list_unlock();

--- swapfile.c.orig     Wed May 16 13:17:32 2001
+++ swapfile.c  Wed May 16 13:18:12 2001
@@ -134,7 +134,7 @@
 bad_count:
        printk(KERN_ERR "get_swap_page: bad count %hd from %p\n",
               count, __builtin_return_address(0));
-       goto out;
+       return entry;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
