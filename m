Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 162676B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 17:05:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w72so4195055wmf.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 14:05:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9si16690336wjp.145.2016.09.29.14.05.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 14:05:57 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 0/4] try to reduce fragmenting fallbacks
Date: Thu, 29 Sep 2016 23:05:44 +0200
Message-Id: <20160929210548.26196-1-vbabka@suse.cz>
In-Reply-To: <20160928014148.GA21007@cmpxchg.org>
References: <20160928014148.GA21007@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

Hi Johannes,

here's something quick to try or ponder about. However, untested since it's too
late here. Based on mmotm-2016-09-27-16-08 plus this fix [1]

[1] http://lkml.kernel.org/r/<cadadd38-6456-f58e-504f-cc18ddc47b3f@suse.cz>

Vlastimil Babka (4):
  mm, compaction: change migrate_async_suitable() to
    suitable_migration_source()
  mm, compaction: add migratetype to compact_control
  mm, compaction: restrict async compaction to matching migratetype
  mm, page_alloc: disallow migratetype fallback in fastpath

 include/linux/mmzone.h |  5 +++++
 mm/compaction.c        | 41 +++++++++++++++++++++++++----------------
 mm/internal.h          |  2 ++
 mm/page_alloc.c        | 34 +++++++++++++++++++++++-----------
 4 files changed, 55 insertions(+), 27 deletions(-)

-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
