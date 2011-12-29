Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id CE1D66B005C
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 23:35:22 -0500 (EST)
Received: by iacb35 with SMTP id b35so27617127iac.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 20:35:22 -0800 (PST)
Date: Wed, 28 Dec 2011 20:35:13 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/3] mm: test PageSwapBacked in lumpy reclaim
In-Reply-To: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112282033260.1362@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org

Lumpy reclaim does well to stop at a PageAnon when there's no swap, but
better is to stop at any PageSwapBacked, which includes shmem/tmpfs too.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm.orig/mm/vmscan.c	2011-12-28 12:32:02.000000000 -0800
+++ mmotm/mm/vmscan.c	2011-12-28 16:49:36.463201033 -0800
@@ -1222,7 +1222,7 @@ static unsigned long isolate_lru_pages(u
 			 * anon page which don't already have a swap slot is
 			 * pointless.
 			 */
-			if (nr_swap_pages <= 0 && PageAnon(cursor_page) &&
+			if (nr_swap_pages <= 0 && PageSwapBacked(cursor_page) &&
 			    !PageSwapCache(cursor_page))
 				break;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
