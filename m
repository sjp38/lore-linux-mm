Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0A46B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 02:15:01 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id q20so54431959ioi.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:15:01 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id t135si11820266pgc.127.2017.01.12.23.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 23:15:00 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id y143so7116273pfb.1
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:14:59 -0800 (PST)
From: js1304@gmail.com
Subject: [RFC PATCH 0/5] pro-active compaction
Date: Fri, 13 Jan 2017 16:14:28 +0900
Message-Id: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello,

This is a patchset for pro-active compaction to reduce fragmentation.
It is a just RFC patchset so implementation detail isn't good.
I submit this for people who want to check the effect of pro-active
compaction.

Patch 1 ~ 4 introduces new metric for checking fragmentation. I think
that this new metric is useful to check fragmentation state
regardless of usefulness of pro-active compaction. Please let me know
if someone see that this new metric is useful. I'd like to submit it,
separately.
	
Any feedback is more than welcome.

Thanks.

Joonsoo Kim (5):
  mm/vmstat: retrieve suitable free pageblock information just once
  mm/vmstat: rename variables/functions about buddyinfo
  mm: introduce exponential moving average to unusable free index
  mm/vmstat: introduce /proc/fraginfo to get fragmentation stat stably
  mm/compaction: run the compaction whenever fragmentation ratio exceeds
    the threshold

 include/linux/mmzone.h |   3 +
 mm/compaction.c        | 280 +++++++++++++++++++++++++++++++++++++++++++++++--
 mm/internal.h          |  21 ++++
 mm/page_alloc.c        |  33 ++++++
 mm/vmstat.c            | 101 ++++++++++++------
 5 files changed, 397 insertions(+), 41 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
