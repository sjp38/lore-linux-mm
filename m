Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 63F846B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 13:04:04 -0500 (EST)
Received: by bkwq16 with SMTP id q16so787924bkw.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 10:04:02 -0800 (PST)
Subject: [PATCH v5 0/7] mm: some cleanup/rework before lru_lock splitting
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 08 Mar 2012 22:03:43 +0400
Message-ID: <20120308175752.27621.54781.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

v5:
* rebase to next-20120308
* reworked cleanup for __isolate_lru_page()
* bloat-o-meter results for each patch

---

Hugh Dickins (2):
      mm/memcg: scanning_global_lru means mem_cgroup_disabled
      mm/memcg: move reclaim_stat into lruvec

Konstantin Khlebnikov (5):
      mm: push lru index into shrink_[in]active_list()
      mm: rework __isolate_lru_page() page lru filter
      mm: rework reclaim_stat counters
      mm/memcg: rework inactive_ratio calculation
      mm/memcg: use vm_swappiness from target memory cgroup


 include/linux/memcontrol.h |   25 -----
 include/linux/mm_inline.h  |    2 
 include/linux/mmzone.h     |   51 ++++-----
 include/linux/swap.h       |    2 
 mm/compaction.c            |    4 -
 mm/memcontrol.c            |   86 ++++------------
 mm/page_alloc.c            |   50 ---------
 mm/swap.c                  |   43 +++-----
 mm/vmscan.c                |  241 +++++++++++++++++++++-----------------------
 mm/vmstat.c                |    6 -
 10 files changed, 178 insertions(+), 332 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
