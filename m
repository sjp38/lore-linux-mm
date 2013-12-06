Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 884A06B004D
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 04:12:31 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so691913pde.13
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 01:12:31 -0800 (PST)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id nu5si20967582pbc.148.2013.12.06.01.12.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Dec 2013 01:12:30 -0800 (PST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 6 Dec 2013 19:12:27 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 856C52CE8051
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 20:12:22 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB69CAfp2949426
	for <linux-mm@kvack.org>; Fri, 6 Dec 2013 20:12:10 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB69CLbU010655
	for <linux-mm@kvack.org>; Fri, 6 Dec 2013 20:12:22 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 2/6] sched/numa: drop idx field of task_numa_env struct 
Date: Fri,  6 Dec 2013 17:12:12 +0800
Message-Id: <1386321136-27538-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Drop unused idx field of task_numa_env struct.

Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
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
