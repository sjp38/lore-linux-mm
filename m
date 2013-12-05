Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f45.google.com (mail-oa0-f45.google.com [209.85.219.45])
	by kanga.kvack.org (Postfix) with ESMTP id 870086B0036
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 06:11:06 -0500 (EST)
Received: by mail-oa0-f45.google.com with SMTP id o6so18300557oag.32
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 03:11:06 -0800 (PST)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id ds9si56642822obc.73.2013.12.05.03.11.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 03:11:05 -0800 (PST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 5 Dec 2013 16:41:01 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id A3C1F3940060
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 16:40:58 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB5BAiLK37683290
	for <linux-mm@kvack.org>; Thu, 5 Dec 2013 16:40:44 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB5BAlhf018475
	for <linux-mm@kvack.org>; Thu, 5 Dec 2013 16:40:47 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 2/2] sched/numa: drop idx field of task_numa_env struct 
Date: Thu,  5 Dec 2013 19:10:17 +0800
Message-Id: <1386241817-5051-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386241817-5051-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386241817-5051-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Drop unused idx field of task_numa_env struct.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 kernel/sched/fair.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index fd773ad..ea3fd1e 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1037,7 +1037,7 @@ struct task_numa_env {
 
 	struct numa_stats src_stats, dst_stats;
 
-	int imbalance_pct, idx;
+	int imbalance_pct;
 
 	struct task_struct *best_task;
 	long best_imp;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
