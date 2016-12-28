Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5DA56B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 10:30:41 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so59421896wmf.3
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 07:30:41 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id r4si21172098wme.125.2016.12.28.07.30.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Dec 2016 07:30:40 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id kp2so54789230wjc.0
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 07:30:40 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/7] mm, vmscan: remove unused mm_vmscan_memcg_isolate
Date: Wed, 28 Dec 2016 16:30:26 +0100
Message-Id: <20161228153032.10821-2-mhocko@kernel.org>
In-Reply-To: <20161228153032.10821-1-mhocko@kernel.org>
References: <20161228153032.10821-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

the trace point is not used since 925b7673cce3 ("mm: make per-memcg LRU
lists exclusive") so it can be removed.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/trace/events/vmscan.h | 31 +------------------------------
 1 file changed, 1 insertion(+), 30 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index c88fd0934e7e..39bad8921ca1 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -269,8 +269,7 @@ TRACE_EVENT(mm_shrink_slab_end,
 		__entry->retval)
 );
 
-DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
-
+TRACE_EVENT(mm_vmscan_lru_isolate,
 	TP_PROTO(int classzone_idx,
 		int order,
 		unsigned long nr_requested,
@@ -311,34 +310,6 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__entry->file)
 );
 
-DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
-
-	TP_PROTO(int classzone_idx,
-		int order,
-		unsigned long nr_requested,
-		unsigned long nr_scanned,
-		unsigned long nr_taken,
-		isolate_mode_t isolate_mode,
-		int file),
-
-	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
-
-);
-
-DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
-
-	TP_PROTO(int classzone_idx,
-		int order,
-		unsigned long nr_requested,
-		unsigned long nr_scanned,
-		unsigned long nr_taken,
-		isolate_mode_t isolate_mode,
-		int file),
-
-	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
-
-);
-
 TRACE_EVENT(mm_vmscan_writepage,
 
 	TP_PROTO(struct page *page),
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
