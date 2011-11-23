Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3896B00C2
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 10:42:59 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/8] mm: memcg fixlets for 3.3
Date: Wed, 23 Nov 2011 16:42:23 +0100
Message-Id: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Here are some minor memcg-related cleanups and optimizations, nothing
too exciting.  The bulk of the diffstat comes from renaming the
remaining variables to describe a (struct mem_cgroup *) to "memcg".
The rest cuts down on the (un)charge fastpaths, as people start to get
annoyed by those functions showing up in the profiles of their their
non-memcg workloads.  More is to come, but I wanted to get the more
obvious bits out of the way.

 include/linux/memcontrol.h  |   16 ++++----
 include/linux/oom.h         |    2 +-
 include/linux/page_cgroup.h |   20 ++++++---
 include/linux/rmap.h        |    4 +-
 mm/memcontrol.c             |   97 ++++++++++++++++---------------------------
 mm/oom_kill.c               |   42 +++++++++---------
 mm/rmap.c                   |   20 ++++----
 mm/swapfile.c               |    9 ++--
 mm/vmscan.c                 |   12 +++---
 9 files changed, 103 insertions(+), 119 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
