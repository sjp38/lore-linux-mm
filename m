Date: Wed, 19 Sep 2007 05:00:06 -0400 (EDT)
From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: [PATCH] MM: Delete gcc-2.95 compatible structure definition.
Message-ID: <Pine.LNX.4.64.0709190458190.9871@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Since nothing earlier than gcc-3.2 is supported for kernel
compilation, that 2.95 hack can be removed.

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>

---

diff --git a/mm/slab.c b/mm/slab.c
index 6f6abef..551700e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -267,11 +267,10 @@ struct array_cache {
 	unsigned int batchcount;
 	unsigned int touched;
 	spinlock_t lock;
-	void *entry[0];	/*
+	void *entry[];	/*
 			 * Must have this definition in here for the proper
 			 * alignment of array_cache. Also simplifies accessing
 			 * the entries.
-			 * [0] is for gcc 2.95. It should really be [].
 			 */
 };

-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
