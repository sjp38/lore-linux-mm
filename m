Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id E61E36B0069
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 04:12:37 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so726601pbc.7
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 01:12:37 -0800 (PST)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id sj5si15079853pab.139.2013.12.06.01.12.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Dec 2013 01:12:36 -0800 (PST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 6 Dec 2013 14:42:33 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id D7D591258056
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 14:43:36 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB69CLn746006282
	for <linux-mm@kvack.org>; Fri, 6 Dec 2013 14:42:21 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB69CS57032188
	for <linux-mm@kvack.org>; Fri, 6 Dec 2013 14:42:28 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 6/6] sched/numa: make numamigrate_update_ratelimit static  
Date: Fri,  6 Dec 2013 17:12:16 +0800
Message-Id: <1386321136-27538-6-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Make numamigrate_update_ratelimit static.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/migrate.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 7ad81e0..1290028 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1592,7 +1592,8 @@ bool migrate_ratelimited(int node)
 }
 
 /* Returns true if the node is migrate rate-limited after the update */
-bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
+static bool numamigrate_update_ratelimit(pg_data_t *pgdat,
+						unsigned long nr_pages)
 {
 	bool rate_limited = false;
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
