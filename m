Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id ED33E6B0073
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 04:08:02 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id g10so4881045pdj.3
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 01:08:02 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id n8si6655856pax.247.2013.12.09.01.08.00
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 01:08:01 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 0/7] correct and clean-up migration related stuff
Date: Mon,  9 Dec 2013 18:10:41 +0900
Message-Id: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Here is the patchset for correcting and cleaning-up migration
related stuff. These are random correction and clean-up, so
please see each patches ;)

Thanks.

Naoya Horiguchi (1):
  mm/migrate: add comment about permanent failure path

Joonsoo Kim (6):
  mm/migrate: correct failure handling if !hugepage_migration_support()
  mm/mempolicy: correct putback method for isolate pages if failed
  mm/migrate: remove putback_lru_pages, fix comment on
    putback_movable_pages
  mm/compaction: respect ignore_skip_hint in update_pageblock_skip
  mm/migrate: remove unused function, fail_migrate_page()
  mm/migrate: remove result argument on page allocation function for
    migration

 include/linux/migrate.h        |    8 +----
 include/linux/page-isolation.h |    3 +-
 mm/compaction.c                |    7 ++--
 mm/memory-failure.c            |   10 ++++--
 mm/mempolicy.c                 |    8 ++---
 mm/migrate.c                   |   74 +++++++++++++---------------------------
 mm/page_isolation.c            |    3 +-
 7 files changed, 44 insertions(+), 69 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
