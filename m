Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 895A86B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 09:40:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u89so13082054wrc.1
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 06:40:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x186si1710695wmb.93.2017.07.20.06.40.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 06:40:40 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/4] page_ext/page_owner init fixes
Date: Thu, 20 Jul 2017 15:40:25 +0200
Message-Id: <20170720134029.25268-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>, Vlastimil Babka <vbabka@suse.cz>

This is a followup to the mail thread [1] where we discussed some issues with
current page_owner (thus also page_ext) init code. Patch 1 should be a
straightforward optimization found during the process. Patches 2 and 3 are
preparation towards patch 4, with the main issue described in its commit log.
It's a RFC because there may be other solutions possible.

[1] http://marc.info/?l=linux-mm&m=149883233221147&w=2

Vlastimil Babka (4):
  mm, page_owner: make init_pages_in_zone() faster
  mm, page_ext: periodically reschedule during page_ext_init()
  mm, page_owner: don't grab zone->lock for init_pages_in_zone()
  mm, page_ext: move page_ext_init() after page_alloc_init_late()

 init/main.c     |  3 ++-
 mm/page_ext.c   |  5 ++---
 mm/page_owner.c | 35 ++++++++++++++++++++++++++++-------
 3 files changed, 32 insertions(+), 11 deletions(-)

-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
