Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 891D66B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 12:51:41 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2 0/2] memcg:add the soft_limit reclaim in global direct reclaim
Date: Mon,  2 May 2011 09:50:23 -0700
Message-Id: <1304355025-1421-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

We recently added the change in global background reclaim which counts the
return value of soft_limit reclaim. Now this patch adds the similar logic
on global direct reclaim.

We should skip scanning global LRU on shrink_zone if soft_limit reclaim does
enough work. This is the first step where we start with counting the nr_scanned
and nr_reclaimed from soft_limit reclaim into global scan_control.

The patch is based on mmotm-2011-04-14-15-08 plus
0001-check-pageunevictable-in-lru_deactivate_fn.patch from Minchan.

Ying Han (2):
  Add the soft_limit reclaim in global direct reclaim.
  Add stats to monitor soft_limit reclaim

 Documentation/cgroups/memory.txt |   16 +++++++--
 mm/memcontrol.c                  |   68 ++++++++++++++++++++++++++++----------
 mm/vmscan.c                      |   16 ++++++++-
 3 files changed, 76 insertions(+), 24 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
