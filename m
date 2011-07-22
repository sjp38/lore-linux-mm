Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 771ED6B0092
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:51:15 -0400 (EDT)
Message-Id: <cover.1311338634.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Fri, 22 Jul 2011 14:43:54 +0200
Subject: [PATCH 0/4 v2] memcg: cleanup per-cpu charge caches
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

Hi,
this is a second version of the per-cpu carge draining code cleanup.
I have dropped the "fix unnecessary reclaim if there are still cached
charges" part because it seems to have some issues and it is not
critical at the moment.

I think that the cleanup has some sense on its own.

Changes since v1:
- memcg: do not try to drain per-cpu caches without pages uses
  drain_cache_local for the current CPU
- added memcg: add mem_cgroup_same_or_subtree helper
- dropped "memcg: prevent from reclaiming if there are per-cpu cached
  charges" patch

Michal Hocko (4):
  memcg: do not try to drain per-cpu caches without pages
  memcg: unify sync and async per-cpu charge cache draining
  memcg: add mem_cgroup_same_or_subtree helper
  memcg: get rid of percpu_charge_mutex lock

 mm/memcontrol.c |  110 +++++++++++++++++++++++++++++++------------------------
 1 files changed, 62 insertions(+), 48 deletions(-)

-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
