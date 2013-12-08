Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 54A026B0039
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 01:15:16 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so3284521pdj.36
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 22:15:16 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id zi8si3349423pac.243.2013.12.07.22.15.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 07 Dec 2013 22:15:15 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 8 Dec 2013 16:15:09 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 5D35B2CE802D
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 17:15:07 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB86Esrw9961728
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 17:14:54 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB86F6RK026801
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 17:15:06 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 05/12] sched/numa: make numamigrate_isolate_page static
Date: Sun,  8 Dec 2013 14:14:46 +0800
Message-Id: <1386483293-15354-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 v2 -> v3:
  * fix patch description

Make numamigrate_isolate_page static.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/migrate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index fdb70f7..7ad81e0 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1616,7 +1616,7 @@ bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
 	return rate_limited;
 }
 
-int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
+static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 {
 	int page_lru;
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
