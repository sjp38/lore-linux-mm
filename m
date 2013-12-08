Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 168646B0035
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 01:20:25 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so3436279pbb.36
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 22:20:24 -0800 (PST)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id ph10si3347700pbb.349.2013.12.07.22.20.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 07 Dec 2013 22:20:23 -0800 (PST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 8 Dec 2013 11:50:20 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id BE58B1258051
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 11:51:24 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB86Gkc360817496
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 11:50:14 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB86FIHj019629
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 11:45:18 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 12/12] sched/numa: drop local 'ret' in task_numa_migrate()
Date: Sun,  8 Dec 2013 14:14:53 +0800
Message-Id: <1386483293-15354-12-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

task_numa_migrate() has two locals called "ret". Fix it all up.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 kernel/sched/fair.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index df8b677..3159ca7 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1257,7 +1257,7 @@ static int task_numa_migrate(struct task_struct *p)
 	p->numa_scan_period = task_scan_min(p);
 
 	if (env.best_task == NULL) {
-		int ret = migrate_task_to(p, env.best_cpu);
+		ret = migrate_task_to(p, env.best_cpu);
 		return ret;
 	}
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
