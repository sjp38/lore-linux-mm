Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D58756B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:39:29 -0500 (EST)
Received: by pfbu66 with SMTP id u66so3178323pfb.3
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 03:39:29 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id u63si19854094pfa.181.2015.12.10.03.39.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 03:39:29 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 0/7] Add swap accounting to cgroup2
Date: Thu, 10 Dec 2015 14:39:13 +0300
Message-ID: <cover.1449742560.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

This patch set adds swap accounting to cgroup2. In contrast to the
legacy hierarchy, actual swap usage is accounted. It can be controlled
and monitored using new files, memory.swap.current and memory.swap.max.
For more details, please see patch 1 of the series, which introduces the
new counter. Patches 2-6 make memcg reclaim follow the heuristics used
on global reclaim for handling anon/swap. Patch 7 updates documentation.

Thanks,

Vladimir Davydov (7):
  mm: memcontrol: charge swap to cgroup2
  mm: vmscan: pass memcg to get_scan_count()
  mm: memcontrol: replace mem_cgroup_lruvec_online with
    mem_cgroup_online
  swap.h: move memcg related stuff to the end of the file
  mm: vmscan: do not scan anon pages if memcg swap limit is hit
  mm: free swap cache aggressively if memcg swap is full
  Documentation: cgroup: add memory.swap.{current,max} description

 Documentation/cgroup.txt   |  16 +++++
 include/linux/memcontrol.h |  28 ++++----
 include/linux/swap.h       |  75 +++++++++++++--------
 mm/memcontrol.c            | 159 ++++++++++++++++++++++++++++++++++++++++++---
 mm/memory.c                |   3 +-
 mm/shmem.c                 |   4 ++
 mm/swap_state.c            |   5 ++
 mm/swapfile.c              |   2 +-
 mm/vmscan.c                |  26 ++++----
 9 files changed, 249 insertions(+), 69 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
