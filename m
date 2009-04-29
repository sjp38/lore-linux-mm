Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3F1346B0047
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 23:09:50 -0400 (EDT)
Date: Wed, 29 Apr 2009 12:09:56 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: [cleanup][PATCH] memcg: remove mem_cgroup_cache_charge_swapin()
Message-Id: <20090429120956.2969b4e4.d-nishimura@mtf.biglobe.ne.jp>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

memcg: remove mem_cgroup_cache_charge_swapin()

mem_cgroup_cache_charge_swapin() isn't used any more, so remove no-op definition
of it in header file.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/swap.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 62d8143..caf0767 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -431,12 +431,6 @@ static inline swp_entry_t get_swap_page(void)
 #define has_swap_token(x) 0
 #define disable_swap_token() do { } while(0)
 
-static inline int mem_cgroup_cache_charge_swapin(struct page *page,
-			struct mm_struct *mm, gfp_t mask, bool locked)
-{
-	return 0;
-}
-
 #endif /* CONFIG_SWAP */
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
