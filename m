Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC856B025E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 09:34:42 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id t7so71643895lbn.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 06:34:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v131si19391371wme.78.2016.04.25.06.34.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Apr 2016 06:34:40 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/3] mainline and mmotm compaction fixes
Date: Mon, 25 Apr 2016 15:34:26 +0200
Message-Id: <1461591269-28615-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

This was initially sent in responses to Hugh's woes [1] but looks like the
timing was unfortunate for the patches to be picked. So here's a consolidated
resent. Patch 1 is for an older bug that Hugh found when dealing with the mmotm
bugs, Patches 2 and 3 are mmotm fixes.

This doesn't address the problem 1) in Hugh's mail, which Michal Hocko also
hit recently and reminded me to check these patches' status:

> 1. Fix crash in release_pages() from compact_zone() from kcompactd_do_work():
>     kcompactd needs to INIT_LIST_HEAD on the new freepages_held list.

This one should be addressed by dropping the following from mmotm from now:

mm-compaction-direct-freepage-allocation-for-async-direct-compaction.patch

As there were objections from Joonsoo and Mel that I would like to try
addressing before posting again.

[1] http://marc.info/?i=alpine.LSU.2.11.1604120005350.1832%40eggly.anvils

Hugh Dickins (2):
  mm, cma: prevent nr_isolated_* counters from going negative
  mm, compaction: prevent nr_isolated_* from going negative

Vlastimil Babka (1):
  mm, compaction: fix crash in get_pfnblock_flags_mask() from
    isolate_freepages():

 mm/compaction.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
