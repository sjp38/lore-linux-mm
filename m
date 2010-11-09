Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CE68D6B00AD
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 20:17:39 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] memcg: correct memcg_hierarchical_free_pages() return type
Date: Mon,  8 Nov 2010 17:17:10 -0800
Message-Id: <1289265430-7190-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

memcg_hierarchical_free_pages() returns a page count and thus
should return unsigned long to be consistent with the rest of
mm code.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b287afd..35870f9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1340,7 +1340,7 @@ static long mem_cgroup_local_page_stat(struct mem_cgroup *mem,
  * use_hierarchy is set, then this involves parent mem cgroups to find the
  * cgroup with the smallest free space.
  */
-static unsigned long long
+static unsigned long
 memcg_hierarchical_free_pages(struct mem_cgroup *mem)
 {
 	unsigned long free, min_free;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
