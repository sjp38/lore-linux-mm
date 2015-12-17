Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 815444402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 07:30:17 -0500 (EST)
Received: by mail-lb0-f171.google.com with SMTP id yq9so25118956lbb.3
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 04:30:17 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id a3si7560513lbi.203.2015.12.17.04.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 04:30:15 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2 0/7] Add swap accounting to cgroup2
Date: Thu, 17 Dec 2015 15:29:53 +0300
Message-ID: <cover.1450352791.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

This is v2 of the patch set introducing swap accounting to cgroup2. For
a detailed description and rationale please see patches 1 and 7.

v1 can be found here: https://lwn.net/Articles/667472/

v2 mostly addresses comments by Johannes. For the detailed changelog,
see individual patches.

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

 Documentation/cgroup.txt   |  33 ++++++++++
 include/linux/memcontrol.h |  28 ++++-----
 include/linux/swap.h       |  76 ++++++++++++++--------
 mm/memcontrol.c            | 154 ++++++++++++++++++++++++++++++++++++++++++---
 mm/memory.c                |   3 +-
 mm/shmem.c                 |   4 ++
 mm/swap_state.c            |   5 ++
 mm/swapfile.c              |   6 +-
 mm/vmscan.c                |  26 ++++----
 9 files changed, 265 insertions(+), 70 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
