From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] 2/4  -ac to newer rmap
Message-Id: <20021113113716Z80365-30305+1116@imladris.surriel.com>
Date: Wed, 13 Nov 2002 09:37:05 -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

remove dead code from page_launder_zone()

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.692   -> 1.693  
#	         mm/vmscan.c	1.79    -> 1.80   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/09/18	riel@duckman.distro.conectiva	1.693
# remove dead code from page_launder_zone()
# --------------------------------------------
#
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Wed Nov 13 08:54:59 2002
+++ b/mm/vmscan.c	Wed Nov 13 08:54:59 2002
@@ -258,15 +258,6 @@
 		if (maxlaunder < 0)
 			gfp_mask &= ~(__GFP_IO|__GFP_FS);
 
-		/* Wrong page on list?! (list corruption, should not happen) */
-		if (!PageInactiveDirty(page)) {
-			printk("VM: page_launder, wrong page on list.\n");
-			list_del(entry);
-			nr_inactive_dirty_pages--;
-			page_zone(page)->inactive_dirty_pages--;
-			continue;
-		}
-
 		/*
 		 * Page is being freed, don't worry about it.
 		 */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
