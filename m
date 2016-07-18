Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69BC06B0264
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 07:23:26 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so112051460lfw.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 04:23:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f197si14236413wmf.73.2016.07.18.04.23.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 04:23:10 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/8] compaction-related cleanups v4
Date: Mon, 18 Jul 2016 13:22:54 +0200
Message-Id: <20160718112302.27381-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

Hi,

this is the splitted-off first part of my "make direct compaction more
deterministic" series [1], rebased on mmotm-2016-07-13-16-09-18. For the whole
series it's probably too late for 4.8 given some unresolved feedback, but I
hope this part could go in as it was stable for quite some time.

At the very least, the first patch really shouldn't wait any longer.

[1] http://marc.info/?l=linux-mm&m=146676211226806&w=2

Hugh Dickins (1):
  mm, compaction: don't isolate PageWriteback pages in
    MIGRATE_SYNC_LIGHT mode

Vlastimil Babka (7):
  mm, page_alloc: set alloc_flags only once in slowpath
  mm, page_alloc: don't retry initial attempt in slowpath
  mm, page_alloc: restructure direct compaction handling in slowpath
  mm, page_alloc: make THP-specific decisions more generic
  mm, thp: remove __GFP_NORETRY from khugepaged and madvised allocations
  mm, compaction: introduce direct compaction priority
  mm, compaction: simplify contended compaction handling

 include/linux/compaction.h        |  33 +++---
 include/linux/gfp.h               |  14 +--
 include/trace/events/compaction.h |  12 +--
 include/trace/events/mmflags.h    |   1 +
 mm/compaction.c                   |  83 ++++-----------
 mm/huge_memory.c                  |  29 ++---
 mm/internal.h                     |   5 +-
 mm/khugepaged.c                   |   2 +-
 mm/migrate.c                      |   2 +-
 mm/page_alloc.c                   | 215 +++++++++++++++++---------------------
 tools/perf/builtin-kmem.c         |   1 +
 11 files changed, 164 insertions(+), 233 deletions(-)

-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
