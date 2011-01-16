Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D25788D0039
	for <linux-mm@kvack.org>; Sun, 16 Jan 2011 15:29:06 -0500 (EST)
Date: Sun, 16 Jan 2011 21:29:03 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] mm: Remove duplicate include of compaction.h from vmscan.c
Message-ID: <alpine.LNX.2.00.1101162125150.13377@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

linux/compaction.h is included twice in mm/vmscan.c - once is enough.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 vmscan.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 99999a9..34edf0a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -41,7 +41,6 @@
 #include <linux/memcontrol.h>
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
-#include <linux/compaction.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
