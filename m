Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 5262C6B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 13:15:51 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2331937dak.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 10:15:50 -0700 (PDT)
From: rajman mekaco <rajman.mekaco@gmail.com>
Subject: [PATCH 1/1] page_alloc.c: remove argument to pageblock_default_order
Date: Thu,  3 May 2012 22:45:12 +0530
Message-Id: <1336065312-2891-1-git-send-email-rajman.mekaco@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rajman mekaco <rajman.mekaco@gmail.com>

When CONFIG_HUGETLB_PAGE_SIZE_VARIABLE is not defined, then
pageblock_default_order has an argument to it.

However, free_area_init_core will call it without any argument
anyway.

Remove the argument to pageblock_default_order when
CONFIG_HUGETLB_PAGE_SIZE_VARIABLE is not defined.

Signed-off-by: rajman mekaco <rajman.mekaco@gmail.com>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a712fb9..4b95412 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4274,7 +4274,7 @@ static inline void __init set_pageblock_order(unsigned int order)
  * at compile-time. See include/linux/pageblock-flags.h for the values of
  * pageblock_order based on the kernel config
  */
-static inline int pageblock_default_order(unsigned int order)
+static inline int pageblock_default_order(void)
 {
 	return MAX_ORDER-1;
 }
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
