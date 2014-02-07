Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D7F416B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 00:08:51 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so2694467pab.15
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 21:08:51 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id x3si3533396pbf.91.2014.02.06.21.08.48
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 21:08:50 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 0/5] compaction related commits
Date: Fri,  7 Feb 2014 14:08:41 +0900
Message-Id: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patchset is related to the compaction.

patch 1 fixes contrary implementation of the purpose of compaction.
patch 2~4 are for optimization.
patch 5 is just for clean-up.

I tested this patchset with stress-highalloc benchmark on Mel's mmtest
and cannot find any regression in terms of success rate. And I find
much reduced system time. Below is result of 3 runs.

* Before
time :: stress-highalloc 3276.26 user 740.52 system 1664.79 elapsed
time :: stress-highalloc 3640.71 user 771.32 system 1633.83 elapsed
time :: stress-highalloc 3691.64 user 775.44 system 1638.05 elapsed

avg system: 1645 s

* After
time :: stress-highalloc 3225.51 user 732.40 system 1542.76 elapsed
time :: stress-highalloc 3524.31 user 749.63 system 1512.88 elapsed
time :: stress-highalloc 3610.55 user 757.20 system 1505.70 elapsed

avg system: 1519 s

That is 7% reduced system time.

Thanks.

Joonsoo Kim (5):
  mm/compaction: disallow high-order page for migration target
  mm/compaction: do not call suitable_migration_target() on every page
  mm/compaction: change the timing to check to drop the spinlock
  mm/compaction: check pageblock suitability once per pageblock
  mm/compaction: clean-up code on success of ballon isolation

 mm/compaction.c |   75 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 39 insertions(+), 36 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
