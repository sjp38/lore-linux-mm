Date: Fri, 15 Jun 2001 19:28:54 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH] vm_enough_memory too generous
Message-ID: <Pine.LNX.4.21.0106151910430.2342-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When free_page_and_swap_cache() went on vacation in April, we had
to compensate in vm_enough_memory(): now it's back, that should go.

Hugh

--- linux-2.4.6-pre3/mm/mmap.c	Thu May 24 23:20:18 2001
+++ linux/mm/mmap.c	Fri Jun 15 19:00:00 2001
@@ -66,14 +66,6 @@
 	free += nr_swap_pages;
 
 	/*
-	 * This double-counts: the nrpages are both in the page-cache
-	 * and in the swapper space. At the same time, this compensates
-	 * for the swap-space over-allocation (ie "nr_swap_pages" being
-	 * too small. 
-	 */
-	free += swapper_space.nrpages;
-
-	/*
 	 * The code below doesn't account for free space in the inode
 	 * and dentry slab cache, slab cache fragmentation, inodes and
 	 * dentries which will become freeable under VM load, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
