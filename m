Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 529F46B000C
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:20:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y20so6816348pfm.1
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 08:20:03 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0107.outbound.protection.outlook.com. [104.47.0.107])
        by mx.google.com with ESMTPS id c2si6138972pgq.675.2018.03.23.08.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 08:20:02 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2 0/4] vmscan per-cgroup reclaim fixes
Date: Fri, 23 Mar 2018 18:20:25 +0300
Message-Id: <20180323152029.11084-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Changes since v1:
 - Added acks.
 - Dropped "mm/vmscan: replace mm_vmscan_lru_shrink_inactive with shrink_page_list tracepoint"
    patch. It's better to avoid changing the tracepoint as some people may be used to it.
    Removing 'nr_scanned' and 'file' arguments is also not very good. Yes, these numbers could
    be obtained from mm_vmscan_lru_isolate tracepoint, but it's easier when it's all in one place.

 - Compare with nr_writeback,dirty, etc only isolated file pages as it always was.
 - Minor changelog tweaks.

Andrey Ryabinin (4):
  mm/vmscan: Update stale comments
  mm/vmscan: remove redundant current_may_throttle() check
  mm/vmscan: Don't change pgdat state on base of a single LRU list
    state.
  mm/vmscan: Don't mess with pgdat->flags in memcg reclaim.

 include/linux/backing-dev.h |   2 +-
 include/linux/memcontrol.h  |   2 +
 mm/backing-dev.c            |  19 ++---
 mm/vmscan.c                 | 166 ++++++++++++++++++++++++++++++--------------
 4 files changed, 122 insertions(+), 67 deletions(-)

-- 
2.16.1
