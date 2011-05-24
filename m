Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 818E96B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 03:02:42 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2] memcg: add documentation for memory.numastat API.
Date: Tue, 24 May 2011 00:01:53 -0700
Message-Id: <1306220513-7763-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

change v2..v1:
1. add sample output.

Signed-off-by: Ying Han <yinghan@google.com>
---
 Documentation/cgroups/memory.txt |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 2d7e527..0b1a1ce 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -71,6 +71,7 @@ Brief summary of control files.
  memory.move_charge_at_immigrate # set/show controls of moving charges
  memory.oom_control		 # set/show oom controls.
  memory.async_control		 # set control for asynchronous memory reclaim
+ memory.numa_stat		 # show the number of memory usage per numa node
 
 1. History
 
@@ -477,6 +478,23 @@ value for efficient access. (Of course, when necessary, it's synchronized.)
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
+The format ouput of the memory.numa_stat:
+
+total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
+file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
+anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
+unevictable=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
+
+And we have total = file + anon + unevictable.
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
