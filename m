Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 628FE6B0035
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 01:50:34 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so1934620pdj.30
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 22:50:34 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id e8si774652pac.111.2013.12.12.22.50.31
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 22:50:33 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 0/6] correct and clean-up migration related stuff
Date: Fri, 13 Dec 2013 15:53:25 +0900
Message-Id: <1386917611-11319-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Changes From v2
- Drop 7th patch which try to remove result argument on page allocation
function for migration since it is wrong.
- Fix one missed word on changelog for 2nd patch, "correct failure
handling if !hugepage_migration_support()"
- Remove missed callsite for putback_lru_pages() on 4th patch
- Add Acked-by and Review-by

Here is the patchset for correcting and cleaning-up migration
related stuff. These are random correction and clean-up, so
please see each patches ;)

Thanks.

Naoya Horiguchi (1):
  mm/migrate: add comment about permanent failure path

Joonsoo Kim (5):
  mm/migrate: correct failure handling if !hugepage_migration_support()
  mm/mempolicy: correct putback method for isolate pages if failed
  mm/migrate: remove putback_lru_pages, fix comment on
    putback_movable_pages
  mm/compaction: respect ignore_skip_hint in update_pageblock_skip
  mm/migrate: remove unused function, fail_migrate_page()

 include/linux/migrate.h |    6 ------
 mm/compaction.c         |    4 ++++
 mm/memory-failure.c     |    8 +++++++-
 mm/mempolicy.c          |    2 +-
 mm/migrate.c            |   51 +++++++++++++++++++----------------------------
 5 files changed, 32 insertions(+), 39 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
