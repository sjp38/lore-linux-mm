Date: Mon, 20 Sep 2004 16:35:32 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Update page-flags.h commentary
Message-ID: <20040920193532.GD5521@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Andrew,

There is no such thing as "page->age" (this was true sometime back in the past).

Update page-flags to reflect it.


--- linux-2.6.9-rc1-mm5/include/linux/page-flags.h.orig	2004-09-20 18:04:51.871654024 -0300
+++ linux-2.6.9-rc1-mm5/include/linux/page-flags.h	2004-09-20 18:05:19.647431464 -0300
@@ -27,8 +27,8 @@
  * For choosing which pages to swap out, inode pages carry a PG_referenced bit,
  * which is set any time the system accesses that page through the (mapping,
  * index) hash table.  This referenced bit, together with the referenced bit
- * in the page tables, is used to manipulate page->age and move the page across
- * the active, inactive_dirty and inactive_clean lists.
+ * in the page tables, is used to move the page across the active, 
+ * inactive_dirty and inactive_clean lists.
  *
  * Note that the referenced bit, the page->lru list_head and the active,
  * inactive_dirty and inactive_clean lists are protected by the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
