Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0986B0253
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 01:35:23 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id le9so16310106pab.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 22:35:23 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id x20si595805pal.165.2016.08.17.22.35.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 22:35:22 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id i6so1110630pfe.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 22:35:22 -0700 (PDT)
Date: Thu, 18 Aug 2016 01:33:45 -0400
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
Subject: [PATCH v2 0/2] Get callbacks/names of shrinkers from tracepoints
Message-ID: <cover.1471496832.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

Currently, it is not possible to know which shrinkers are being run.
Even though the callbacks are printed using %pF in tracepoints 
mm_shrink_slab_start and mm_shrink_slab_end, they are not visible to
userspace tools like perf.

To address this, this patchset
1. Enables the display of names of shrinker callbacks in tracepoints
mm_shrink_slab_start and mm_shrink_slab_end.
2. Adds a new tracepoint in the callback of the superblock shrinker to
get specific names of superblock types.

Changes since v1 at https://lkml.org/lkml/2016/7/9/33:
1. This patchset does not introduce a new variable to hold names of
shrinkers, unlike v1. It makes mm_shrink_slab_start and
mm_shrink_slab_end print names of callbacks instead.
2. It also adds a new tracepoint for superblock shrinkers to display
more specific name information, which v1 did not do.

Thanks to Dave Chinner and Tony Jones for their suggestions.

Janani Ravichandran (2):
  include: trace: Display names of shrinker callbacks
  fs: super.c: Add tracepoint to get name of superblock shrinker

 fs/super.c                    |  2 ++
 include/trace/events/vmscan.h | 39 +++++++++++++++++++++++++++++++++++++--
 2 files changed, 39 insertions(+), 2 deletions(-)

-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
