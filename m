Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8814B6B002B
	for <linux-mm@kvack.org>; Mon, 16 May 2011 18:02:08 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] memcg: fix typo in the soft_limit stats.
Date: Mon, 16 May 2011 15:00:30 -0700
Message-Id: <1305583230-2111-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This fixes the typo in the memory.stat including the following two
stats:

$ cat /dev/cgroup/memory/A/memory.stat
total_soft_steal 0
total_soft_scan 0

And change it to:

$ cat /dev/cgroup/memory/A/memory.stat
total_soft_kswapd_steal 0
total_soft_kswapd_scan 0

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/memcontrol.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a010c23..1ea787d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4023,8 +4023,8 @@ struct {
 	{"limit_direct_scan", "total_limit_direct_scan"},
 	{"hierarchy_direct_steal", "total_hierarchy_direct_steal"},
 	{"hierarchy_direct_scan", "total_hierarchy_direct_scan"},
-	{"soft_kswapd_steal", "total_soft_steal"},
-	{"soft_kswapd_scan", "total_soft_scan"},
+	{"soft_kswapd_steal", "total_soft_kswapd_steal"},
+	{"soft_kswapd_scan", "total_soft_kswapd_scan"},
 	{"soft_direct_steal", "total_soft_direct_steal"},
 	{"soft_direct_scan", "total_soft_direct_scan"},
 	{"inactive_anon", "total_inactive_anon"},
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
