Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA00322
	for <linux-mm@kvack.org>; Mon, 9 Mar 1998 16:04:44 -0500
Date: Mon, 9 Mar 1998 20:54:56 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: swapout frenzy quick-fix
Message-ID: <Pine.LNX.3.91.980309205216.2479A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: jasons@usemail.com
Cc: linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi Jason and Linus,

I made a quick-fix for the swapout frenzy occurring in
2.1.89...
It's far from perfect, but until the changes from Ben
and Stephen are merged, it'll have to do :-(

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+

--- linux/mm/vmscan.c.orig	Mon Mar  9 20:51:44 1998
+++ linux/mm/vmscan.c	Mon Mar  9 20:51:44 1998
@@ -573,6 +573,8 @@
 
 			if (free_memory_available())
 				break;
+			if (nr_free_pages + atomic_read(&nr_async_pages) > free_pages_high * 4)
+				break;
 			gfp_mask = __GFP_IO;
 			try_to_free_page(gfp_mask);
 			/*
