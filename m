Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 263FC6B004D
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 02:20:02 -0400 (EDT)
Date: Fri, 14 Aug 2009 15:16:30 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [cleanup][2/2] mm: add_to_swap_cache() does not return -EEXIST
Message-Id: <20090814151630.950e5cd9.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090810112716.fb110c5a.nishimura@mxp.nes.nec.co.jp>
References: <20090810112326.3526b11d.nishimura@mxp.nes.nec.co.jp>
	<20090810112716.fb110c5a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew, this is a minor fix for mm-add_to_swap_cache-does-not-return-eexist.patch.

It didn't catch up with the change in [1/2](mm-add_to_swap_cache-must-not-sleep.patch).

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

fix indent size.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/swap_state.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index ff5bd8c..6d1daeb 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -92,12 +92,12 @@ static int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 	spin_unlock_irq(&swapper_space.tree_lock);
 
 	if (unlikely(error)) {
-			/*
-			 * Only the context which have set SWAP_HAS_CACHE flag
-			 * would call add_to_swap_cache().
-			 * So add_to_swap_cache() doesn't returns -EEXIST.
-			 */
-			VM_BUG_ON(error == -EEXIST);
+		/*
+		 * Only the context which have set SWAP_HAS_CACHE flag
+		 * would call add_to_swap_cache().
+		 * So add_to_swap_cache() doesn't returns -EEXIST.
+		 */
+		VM_BUG_ON(error == -EEXIST);
 		set_page_private(page, 0UL);
 		ClearPageSwapCache(page);
 		page_cache_release(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
