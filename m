Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id DB82B6B0256
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 16:00:53 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id u188so123323397wmu.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:00:53 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v186si7790107wmb.62.2016.01.26.13.00.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 13:00:52 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/5] mm: workingset: per-cgroup thrash detection
Date: Tue, 26 Jan 2016 16:00:01 -0500
Message-Id: <1453842006-29265-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi,

these patches make the workingset code cgroup-aware, so that page
reclaim works properly when using the cgroup memory controller. More
details in the 5/5 changelog.

This should have been part of the original thrash detection patches,
but those were already too complex. So here we go.

Thanks,
Johannes

 fs/buffer.c                |  14 ++--
 fs/xfs/xfs_aops.c          |   8 +--
 include/linux/memcontrol.h |  55 ++++++++++++++--
 include/linux/mmzone.h     |  11 ++--
 include/linux/swap.h       |   1 +
 mm/filemap.c               |  12 ++--
 mm/memcontrol.c            |  59 ++++-------------
 mm/page-writeback.c        |  28 ++++----
 mm/rmap.c                  |   8 +--
 mm/truncate.c              |   6 +-
 mm/vmscan.c                |  26 ++++----
 mm/workingset.c            | 151 ++++++++++++++++++++++++++++++++-----------
 12 files changed, 236 insertions(+), 143 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
