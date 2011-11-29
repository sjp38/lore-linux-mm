Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1F76B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 05:52:38 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/7] mm: memcg fixlets for 3.3 v2
Date: Tue, 29 Nov 2011 11:51:58 +0100
Message-Id: <1322563925-1667-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Version 2:
o dropped the non-atomic bitops against pc->flags (Hugh et al)
o added VM_BUG_ONs where page sanity checks were removed (Kame)
o made the page_cgroup array checks in lookup_page_cgroup()
  depend on CONFIG_DEBUG_VM, like the only caller that needs 'em
o added ack tags

 include/linux/memcontrol.h |   16 ++++----
 include/linux/oom.h        |    2 +-
 include/linux/rmap.h       |    4 +-
 mm/memcontrol.c            |   96 ++++++++++++++++++--------------------------
 mm/oom_kill.c              |   42 ++++++++++----------
 mm/page_cgroup.c           |   18 +++++++-
 mm/rmap.c                  |   20 +++++-----
 mm/swapfile.c              |    9 ++--
 mm/vmscan.c                |   12 +++---
 9 files changed, 108 insertions(+), 111 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
