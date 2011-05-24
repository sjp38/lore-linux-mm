Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DB8346B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 02:27:01 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] memcg: add documentation for memory.numastat API.
Date: Mon, 23 May 2011 23:26:14 -0700
Message-Id: <1306218374-5597-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org


Signed-off-by: Ying Han <yinghan@google.com>
---
 Documentation/cgroups/memory.txt |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 2d7e527..b81be08 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -71,6 +71,7 @@ Brief summary of control files.
  memory.move_charge_at_immigrate # set/show controls of moving charges
  memory.oom_control		 # set/show oom controls.
  memory.async_control		 # set control for asynchronous memory reclaim
+ memory.numa_stat		 # show the number of memory usage per numa node
 
 1. History
 
@@ -477,6 +478,15 @@ value for efficient access. (Of course, when necessary, it's synchronized.)
 If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
 value in memory.stat(see 5.2).
 
+5.6 numa_stat
+
+This is similar to numa_maps but per-memcg basis. This is useful to add visibility
+of numa locality information in memcg since the pages are allowed to be allocated
+at any physical node. One of the usecase is evaluating application performance by
+combining this information with the cpu allocation to the application.
+
+We export "total", "file", "anon" and "unevictable" pages per-node for each memcg.
+
 6. Hierarchy support
 
 The memory controller supports a deep hierarchy and hierarchical accounting.
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
