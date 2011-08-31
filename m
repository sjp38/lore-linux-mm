Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C877E6B00EE
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 13:32:32 -0400 (EDT)
From: Viktor Rosendahl <viktor.rosendahl@nokia.com>
Subject: [PATCH] Enable OOM when moving processes between cgroups?
Date: Wed, 31 Aug 2011 20:32:21 +0300
Message-Id: <1314811941-14587-1-git-send-email-viktor.rosendahl@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>

Hello,

I wonder if there is a specific reason why the  OOM killer hasn't been enabled
in the mem_cgroup_do_precharge() function in mm/memcontrol.c ?

In my testing (2.6.32 kernel with some backported cgroups patches), it improves
the case when there isn't room for the task in the target cgroup.

Signed-off-by: Viktor Rosendahl <viktor.rosendahl@nokia.com>
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ebd1e86..9a38b80 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5176,7 +5176,7 @@ one_by_one:
 			batch_count = PRECHARGE_COUNT_AT_ONCE;
 			cond_resched();
 		}
-		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, 1, &mem, false);
+		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, 1, &mem, true);
 		if (ret || !mem)
 			/* mem_cgroup_clear_mc() will do uncharge later */
 			return -ENOMEM;
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
