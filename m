Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3C56B0278
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 12:20:36 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l132so87861291wmf.0
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 09:20:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si17769886wjg.51.2016.09.26.09.20.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Sep 2016 09:20:33 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/4] followups to reintroduce compaction feedback for OOM decisions
Date: Mon, 26 Sep 2016 18:20:21 +0200
Message-Id: <20160926162025.21555-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, Rik van Riel <riel@redhat.com>

Reviews of series "reintroduce compaction feedback for OOM decisions" [1]
resulted in some followup patches and Michal suggested posting them in a new
threads, so here it goes.

Patch 1 is meant to be squashed into the following patch in mmotm:
mm-compaction-more-reliably-increase-direct-compaction-priority.patch

Patch 2 is a cleanup for consistency. Patches 3 and 4 deal with the last
(hopefully) remaining heuristic in the reclaim/compaction-vs-OOM scenario,
which is the fragmentation index.

[1] http://www.spinics.net/lists/linux-mm/msg113133.html

Vlastimil Babka (4):
  mm, compaction: more reliably increase direct compaction priority-fix
  mm, page_alloc: pull no_progress_loops update to
    should_reclaim_retry()
  mm, compaction: ignore fragindex from compaction_zonelist_suitable()
  mm, compaction: restrict fragindex to costly orders

 mm/compaction.c | 42 ++++++++++++++++++++++++------------------
 mm/page_alloc.c | 47 ++++++++++++++++++++++++-----------------------
 2 files changed, 48 insertions(+), 41 deletions(-)

-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
