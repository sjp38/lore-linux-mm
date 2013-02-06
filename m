Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 4390F6B0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 00:20:48 -0500 (EST)
Message-ID: <5111E7D0.5030409@cn.fujitsu.com>
Date: Wed, 06 Feb 2013 13:19:12 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 5/7] vmscan: change type of vm_total_pages to unsigned long
References: <5111E612.4010907@cn.fujitsu.com>
In-Reply-To: <5111E612.4010907@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

This variable is calculated from nr_free_pagecache_pages so
change its type to unsigned long.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/swap.h |    2 +-
 mm/vmscan.c          |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index c238323..fa1f686 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -266,7 +266,7 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
-extern long vm_total_pages;
+extern unsigned long vm_total_pages;
 
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 196709f..5344a5b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -128,7 +128,7 @@ struct scan_control {
  * From 0 .. 100.  Higher means more swappy.
  */
 int vm_swappiness = 60;
-long vm_total_pages;	/* The total number of pages which the VM controls */
+unsigned long vm_total_pages;	/* The total number of pages which the VM controls */
 
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
