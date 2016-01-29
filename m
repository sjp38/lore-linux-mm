Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2006B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 18:20:25 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p63so146504wmp.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 15:20:25 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id un8si2087498wjc.169.2016.01.29.15.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 15:20:23 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/3] mm: memcontrol: simplify page->mem_cgroup pinning
Date: Fri, 29 Jan 2016 18:19:30 -0500
Message-Id: <1454109573-29235-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

This simplifies the way page->mem_cgroup is pinned. After this series,
lock_page_memcg() is simpler to use, and only necessary if the page is
neither isolated from the LRU nor fully locked.

 fs/buffer.c                | 18 ++++++++---------
 fs/xfs/xfs_aops.c          |  7 +++----
 include/linux/memcontrol.h | 46 ++++++++++++++++++++++---------------------
 include/linux/mm.h         | 14 ++-----------
 include/linux/pagemap.h    |  3 +--
 mm/filemap.c               | 21 ++++++--------------
 mm/memcontrol.c            | 36 +++++++++++++++------------------
 mm/migrate.c               | 14 +++++++------
 mm/page-writeback.c        | 47 ++++++++++++++++++--------------------------
 mm/rmap.c                  | 16 ++++++---------
 mm/shmem.c                 |  2 +-
 mm/truncate.c              |  6 +-----
 mm/vmscan.c                |  7 +------
 mm/workingset.c            |  9 ++++-----
 14 files changed, 100 insertions(+), 146 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
