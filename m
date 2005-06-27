Date: Mon, 27 Jun 2005 06:58:29 -0400
From: Bob Picco <bob.picco@hp.com>
Subject: [PATCH] fix WANT_PAGE_VIRTUAL in memmap_init
Message-ID: <20050627105829.GX23911@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, bob.picco@hp.com
List-ID: <linux-mm.kvack.org>

I spotted this issue while in memmap_init last week.  I can't say the change has
any test coverage by me.  start_pfn was formerly used in main "for" loop.
The fix is replace start_pfn with pfn.

bob

Signed-off-by: Bob Picco <bob.picco@hp.com>

Index: linux-2.6.12-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.12-mm1.orig/mm/page_alloc.c	2005-06-23 14:18:09.000000000 -0400
+++ linux-2.6.12-mm1/mm/page_alloc.c	2005-06-23 14:19:46.000000000 -0400
@@ -1720,9 +1720,8 @@ void __init memmap_init_zone(unsigned lo
 #ifdef WANT_PAGE_VIRTUAL
 		/* The shift won't overflow because ZONE_NORMAL is below 4G. */
 		if (!is_highmem_idx(zone))
-			set_page_address(page, __va(start_pfn << PAGE_SHIFT));
+			set_page_address(page, __va(pfn << PAGE_SHIFT));
 #endif
-		start_pfn++;
 #ifdef CONFIG_PAGE_OWNER
 		page->order = -1;
 #endif
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
