Received: from freak.mileniumnet.com.br (IDENT:maluco@freak.mileniumnet.com.br [200.199.222.9])
	by strauss.mileniumnet.com.br (8.9.3/8.9.3) with ESMTP id OAA07530
	for <linux-mm@kvack.org>; Fri, 18 May 2001 14:30:20 -0300
Date: Fri, 18 May 2001 13:20:06 -0400 (AMT)
From: Thiago Rondon <maluco@mileniumnet.com.br>
Subject: [PATCH] mm/swap_stat.c
Message-ID: <Pine.LNX.4.21.0105181319350.8753-100000@freak.mileniumnet.com.br>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Just change BUG to PAGE_BUG when necessary, Comments?

--- swap_state.c.orig   Thu May 17 13:00:33 2001
+++ swap_state.c        Thu May 17 13:01:30 2001
@@ -74,9 +74,9 @@
        swap_cache_add_total++;
 #endif
        if (!PageLocked(page))
-               BUG();
+               PAGE_BUG(page);
        if (PageTestandSetSwapCache(page))
-               BUG();
+               PAGE_BUG(page);
        if (page->mapping)
                BUG();
        flags = page->flags & ~((1 << PG_error) | (1 << PG_arch_1));
@@ -122,7 +122,7 @@
 void delete_from_swap_cache_nolock(struct page *page)
 {
        if (!PageLocked(page))
-               BUG();
+               PAGE_BUG(bug);

        if (block_flushpage(page, 0))
                lru_cache_del(page);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
