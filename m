Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E80D56B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 15:23:19 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] memcg: mark mem_cgroup_page_stat() underflow unlikely
Date: Tue,  9 Nov 2010 12:21:58 -0800
Message-Id: <1289334118-4448-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

Add unlikely() to indicate that underflow of per-cpu counter
sum is not expected.

The underflow is already handled, but should have been
marked unlikely.

Reported-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ed070d0..e8fbade 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1393,7 +1393,7 @@ unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
 	 * value.  This function returns an unsigned value, so round it up to
 	 * zero to avoid returning a very large value.
 	 */
-	if (value < 0)
+	if (unlikely(value < 0))
 		value = 0;
 
 	put_online_cpus();
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
