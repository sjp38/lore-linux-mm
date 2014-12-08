Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 30CC06B0038
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 02:12:42 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id y10so4624377pdj.21
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 23:12:41 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id pm2si55415579pdb.18.2014.12.07.23.12.39
        for <linux-mm@kvack.org>;
        Sun, 07 Dec 2014 23:12:41 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 0/4] enhance compaction success rate
Date: Mon,  8 Dec 2014 16:16:16 +0900
Message-Id: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patchset aims at increase of compaction success rate. Changes are
related to compaction finish condition and freepage isolation condition.

>From these changes, I did stress highalloc test in mmtests with nonmovable
order 7 allocation configuration, and success rate (%) at phase 1 are,

Base	Patch-1	Patch-3	Patch-4
55.00	57.00	62.67	64.00

And, compaction success rate (%) on same test are,

Base	Patch-1	Patch-3	Patch-4
18.47	28.94	35.13	41.50

This patchset is based on my tracepoint update on compaction.

https://lkml.org/lkml/2014/12/3/71

Joonsoo Kim (4):
  mm/compaction: fix wrong order check in compact_finished()
  mm/page_alloc: expands broken freepage to proper buddy list when
    steal
  mm/compaction: enhance compaction finish condition
  mm/compaction: stop the isolation when we isolate enough freepage

 include/linux/mmzone.h      |    3 ++
 include/trace/events/kmem.h |    7 +++--
 mm/compaction.c             |   48 ++++++++++++++++++++++------
 mm/internal.h               |    1 +
 mm/page_alloc.c             |   73 +++++++++++++++++++++++++------------------
 5 files changed, 89 insertions(+), 43 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
