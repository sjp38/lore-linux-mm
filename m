Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 52FF36B007E
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 17:56:17 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so2948567bkw.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2012 14:56:15 -0700 (PDT)
Subject: [PATCH v6 0/7] mm: some simple cleanups
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 23 Mar 2012 01:56:12 +0400
Message-ID: <20120322214944.27814.42039.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

I left here only small and simple patches, some of them already acked.

Patch for lru filters in __isolate_lru_page() was reworked again: we can remove all
these checks, because lumpy isolation in shrink_active_list() now forbidden.

---

Hugh Dickins (2):
      mm/memcg: scanning_global_lru means mem_cgroup_disabled
      mm/memcg: move reclaim_stat into lruvec

Konstantin Khlebnikov (5):
      mm: push lru index into shrink_[in]active_list()
      mm: mark mm-inline functions as __always_inline
      mm: remove lru type checks from __isolate_lru_page()
      mm/memcg: kill mem_cgroup_lru_del()
      mm/memcg: use vm_swappiness from target memory cgroup


 include/linux/memcontrol.h |   14 ------
 include/linux/mm_inline.h  |    8 ++-
 include/linux/mmzone.h     |   39 +++++++---------
 include/linux/swap.h       |    2 -
 mm/compaction.c            |    4 +-
 mm/memcontrol.c            |   32 +++----------
 mm/page_alloc.c            |    8 ++-
 mm/swap.c                  |   14 ++----
 mm/vmscan.c                |  105 +++++++++++++++-----------------------------
 9 files changed, 74 insertions(+), 152 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
