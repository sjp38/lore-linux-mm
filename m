From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] 1/4  -ac to newer rmap
Message-Id: <20021113113717Z80339-30305+1117@imladris.surriel.com>
Date: Wed, 13 Nov 2002 09:37:05 -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.691   -> 1.692  
#	         mm/vmscan.c	1.78    -> 1.79   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/09/18	riel@duckman.distro.conectiva	1.692
# make OOM detection a bit more agressive
# --------------------------------------------
#
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Wed Nov 13 08:54:45 2002
+++ b/mm/vmscan.c	Wed Nov 13 08:54:45 2002
@@ -691,7 +691,7 @@
 	 * Hmm.. Cache shrink failed - time to kill something?
 	 * Mhwahahhaha! This is the part I really like. Giggle.
 	 */
-	if (!ret && free_min(ANY_ZONE) > 0)
+	if (ret < free_low(ANY_ZONE))
 		out_of_memory();
 
 	return ret;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
