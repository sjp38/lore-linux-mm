Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BC53E8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 08:51:55 -0400 (EDT)
Received: by fxm18 with SMTP id 18so3407103fxm.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:51:49 -0700 (PDT)
Subject: [PATCH] memcg: fix mem_cgroup_rotate_reclaimable_page
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20110221155925.GA5641@barrios-desktop>
References: <cover.1298212517.git.minchan.kim@gmail.com>
	 <c76a1645aac12c3b8ffe2cc5738033f5a6da8d32.1298212517.git.minchan.kim@gmail.com>
	 <20110221084014.GC25382@cmpxchg.org>
	 <20110221155925.GA5641@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Mar 2011 14:51:46 +0200
Message-ID: <1301316706.3182.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Le mardi 22 fA(C)vrier 2011 A  00:59 +0900, Minchan Kim a A(C)crit :
> Fixed version.
> 
> From be7d31f6e539bbad1ebedf52c6a51a4a80f7976a Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan.kim@gmail.com>
> Date: Tue, 22 Feb 2011 00:53:05 +0900
> Subject: [PATCH v7 2/3] memcg: move memcg reclaimable page into tail of inactive list
> 
> The rotate_reclaimable_page function moves just written out
> pages, which the VM wanted to reclaim, to the end of the
> inactive list.  That way the VM will find those pages first
> next time it needs to free memory.
> This patch apply the rule in memcg.
> It can help to prevent unnecessary working page eviction of memcg.
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---

Hmm... "inline inline" is an error on some gcc versions

  CC      arch/x86/kernel/asm-offsets.s
In file included from include/linux/swap.h:8,
                 from include/linux/suspend.h:4,
                 from arch/x86/kernel/asm-offsets.c:12:
include/linux/memcontrol.h:220: error: duplicate `inline'
make[1]: *** [arch/x86/kernel/asm-offsets.s] Error 1


> +static inline inline void mem_cgroup_rotate_reclaimable_page(struct page *page)
> +{
> +	return ;
> +}
> +

[PATCH] memcg: fix mem_cgroup_rotate_reclaimable_page proto

commit 3f58a8294333 (move memcg reclaimable page into tail of inactive
list) added inline keyword twice in its prototype.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5a5ce70..5e9840f5 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -216,7 +216,7 @@ static inline void mem_cgroup_del_lru_list(struct page *page, int lru)
 	return ;
 }
 
-static inline inline void mem_cgroup_rotate_reclaimable_page(struct page *page)
+static inline void mem_cgroup_rotate_reclaimable_page(struct page *page)
 {
 	return ;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
