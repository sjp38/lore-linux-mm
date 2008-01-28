Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m0S4eKWe022586
	for <linux-mm@kvack.org> (envelope-from kusumi.tomohiro@jp.fujitsu.com);
	Mon, 28 Jan 2008 13:40:20 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C6302AC026
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 13:40:20 +0900 (JST)
Received: from s10.gw.fujitsu.co.jp (s10.gw.fujitsu.co.jp [10.0.50.80])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D89B112C084
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 13:40:19 +0900 (JST)
Received: from s10.gw.fujitsu.co.jp (s10 [127.0.0.1])
	by s10.gw.fujitsu.co.jp (Postfix) with ESMTP id BE45F161C007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 13:40:19 +0900 (JST)
Received: from fjm501.ms.jp.fujitsu.com (fjm501.ms.jp.fujitsu.com [10.56.99.71])
	by s10.gw.fujitsu.co.jp (Postfix) with ESMTP id AE292161C00D
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 13:40:18 +0900 (JST)
Received: from fjmscan503.ms.jp.fujitsu.com (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm501.ms.jp.fujitsu.com with ESMTP id m0S4diTP022146
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 13:39:44 +0900
Received: from [127.0.0.1] ([10.33.110.61])
	by fjmscan503.ms.jp.fujitsu.com (8.13.1/8.12.11) with ESMTP id m0S4dgAm001211
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 13:39:44 +0900
Message-ID: <479D5CDE.6060201@jp.fujitsu.com>
Date: Mon, 28 Jan 2008 13:41:02 +0900
From: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] change comment in read_swap_cache_async
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

The function try_to_swap_out seems to have been removed in 2.5 era.
So shouldn't the following comment get changed ?

Tomohiro Kusumi
Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>

diff -Nurp linux-2.6.24.org/mm/swap_state.c linux-2.6.24/mm/swap_state.c
--- linux-2.6.24.org/mm/swap_state.c	2008-01-28 13:22:41.000000000 +0900
+++ linux-2.6.24/mm/swap_state.c	2008-01-28 13:26:07.000000000 +0900
@@ -349,8 +349,8 @@ struct page *read_swap_cache_async(swp_e
 		 * our caller observed it.  May fail (-EEXIST) if there
 		 * is already a page associated with this entry in the
 		 * swap cache: added by a racing read_swap_cache_async,
-		 * or by try_to_swap_out (or shmem_writepage) re-using
-		 * the just freed swap entry for an existing page.
+		 * or by shmem_writepage re-using the just freed swap
+		 * entry for an existing page.
 		 * May fail (-ENOMEM) if radix-tree node allocation failed.
 		 */
 		err = add_to_swap_cache(new_page, entry);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
