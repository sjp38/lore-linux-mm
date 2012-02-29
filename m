Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 732E46B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 04:15:41 -0500 (EST)
Received: by bkwq16 with SMTP id q16so99930bkw.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 01:15:39 -0800 (PST)
Subject: [PATCH v4 ch1 0/7] mm: some cleanup/rework before lru_lock splitting
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 29 Feb 2012 13:15:33 +0400
Message-ID: <20120229090748.29236.35489.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Here is some cleanup/rework patches from Hugh Dickins and me.
This is about one-third of my current patchset,
so I prefer to merge this set before going further.

---

Hugh Dickins (2):
      mm/memcg: scanning_global_lru means mem_cgroup_disabled
      mm/memcg: move reclaim_stat into lruvec

Konstantin Khlebnikov (5):
      mm: rework __isolate_lru_page() file/anon filter
      mm: push lru index into shrink_[in]active_list()
      mm: rework reclaim_stat counters
      mm/memcg: rework inactive_ratio calculation
      mm/memcg: use vm_swappiness from target memory cgroup


 include/linux/memcontrol.h |   25 -----
 include/linux/mmzone.h     |   43 ++++----
 include/linux/swap.h       |    2 
 mm/compaction.c            |    5 +
 mm/memcontrol.c            |   86 ++++-------------
 mm/page_alloc.c            |   50 ----------
 mm/swap.c                  |   40 ++------
 mm/vmscan.c                |  225 ++++++++++++++++++++++----------------------
 mm/vmstat.c                |    6 -
 9 files changed, 173 insertions(+), 309 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
