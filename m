Date: Wed, 18 Aug 1999 19:06:22 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: [patch] not needed lock_queue
Message-ID: <Pine.LNX.4.10.9908181905390.16546-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

lock_queue is swap-lockmap dead code.

--- 2.3.14-pre1/mm/page_io.c	Thu Aug 12 02:53:25 1999
+++ /tmp/page_io.c	Wed Aug 18 19:05:07 1999
@@ -18,8 +18,6 @@
 
 #include <asm/pgtable.h>
 
-static DECLARE_WAIT_QUEUE_HEAD(lock_queue);
-
 /*
  * Reads or writes a swap page.
  * wait=1: start I/O and wait for completion. wait=0: start asynchronous I/O.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
