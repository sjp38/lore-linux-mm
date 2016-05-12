Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD2A6B007E
	for <linux-mm@kvack.org>; Thu, 12 May 2016 07:14:44 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 68so22014038lfq.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 04:14:43 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 71si44845098wmr.122.2016.05.12.04.14.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 04:14:42 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w143so15302367wmw.3
        for <linux-mm@kvack.org>; Thu, 12 May 2016 04:14:42 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mmotm: mm-oom-rework-oom-detection-fix
Date: Thu, 12 May 2016 13:14:36 +0200
Message-Id: <1463051677-29418-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1463051677-29418-1-git-send-email-mhocko@kernel.org>
References: <1463051677-29418-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

watermark check should use classzone_idx rather than high_zoneidx
to check reserves against the correct (preferred) zone.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0d9008042efa..620ec002aea2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3496,7 +3496,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		 * available?
 		 */
 		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
-				ac->high_zoneidx, alloc_flags, available)) {
+				ac_classzone_idx(ac), alloc_flags, available)) {
 			/*
 			 * If we didn't make any progress and have a lot of
 			 * dirty + writeback pages then we should wait for
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
