From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051208112950.6309.72290.sendpatchset@cherry.local>
In-Reply-To: <20051208112940.6309.39428.sendpatchset@cherry.local>
References: <20051208112940.6309.39428.sendpatchset@cherry.local>
Subject: [PATCH 02/07] Add PG_mapped
Date: Thu,  8 Dec 2005 20:27:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Add PG_mapped.

This patch adds a PG_mapped bit to page->flags to be able to track if a page
is unmapped or not. PG_mapped should be interpreted as follows:

0: Page is guaranteed to be unmapped.
1: Page is either mapped or unmapped.

The bit could be read without locks, but will be set under PG_locked.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 page-flags.h |    5 +++++
 1 files changed, 5 insertions(+)

--- from-0002/include/linux/page-flags.h
+++ to-work/include/linux/page-flags.h	2005-12-08 14:58:52.000000000 +0900
@@ -75,6 +75,7 @@
 #define PG_reclaim		17	/* To be reclaimed asap */
 #define PG_nosave_free		18	/* Free, should not be written */
 #define PG_uncached		19	/* Page has been mapped as uncached */
+#define PG_mapped		20	/* Page might be mapped in a vma */
 
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
@@ -303,6 +304,10 @@ extern void __mod_page_state(unsigned lo
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#define PageMapped(page)	test_bit(PG_mapped, &(page)->flags)
+#define TestSetPageMapped(page)	test_and_set_bit(PG_mapped, &(page)->flags)
+#define ClearPageMapped(page)	clear_bit(PG_mapped, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 int test_clear_page_dirty(struct page *page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
