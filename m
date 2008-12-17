Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2CB916B00A2
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 06:25:48 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBHBRV3G013880
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 17 Dec 2008 20:27:31 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C03345DE52
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 20:27:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AD5545DE51
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 20:27:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 01D051DB8014
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 20:27:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AD5A51DB8012
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 20:27:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm: kill page_queue_congested()
Message-Id: <20081217202547.FF22.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 17 Dec 2008 20:27:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


==
Subject: [PATCH] mm: kill page_queue_congested()

page_queue_congested() was introduced at 2002.
but it is unused until now at all.

it can be removed.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/swapfile.c |   20 --------------------
 1 file changed, 20 deletions(-)

Index: b/mm/swapfile.c
===================================================================
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1203,26 +1203,6 @@ out:
 	return ret;
 }
 
-#if 0	/* We don't need this yet */
-#include <linux/backing-dev.h>
-int page_queue_congested(struct page *page)
-{
-	struct backing_dev_info *bdi;
-
-	BUG_ON(!PageLocked(page));	/* It pins the swap_info_struct */
-
-	if (PageSwapCache(page)) {
-		swp_entry_t entry = { .val = page_private(page) };
-		struct swap_info_struct *sis;
-
-		sis = get_swap_info_struct(swp_type(entry));
-		bdi = sis->bdev->bd_inode->i_mapping->backing_dev_info;
-	} else
-		bdi = page->mapping->backing_dev_info;
-	return bdi_write_congested(bdi);
-}
-#endif
-
 asmlinkage long sys_swapoff(const char __user * specialfile)
 {
 	struct swap_info_struct * p = NULL;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
