Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 51CC76B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 19:12:35 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so10462224pde.14
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 16:12:34 -0800 (PST)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id u7si1180409pbh.292.2013.12.11.16.12.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 16:12:34 -0800 (PST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 12 Dec 2013 05:42:30 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 64659E0053
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:44:47 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBC0CNhj6291784
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:42:24 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBC0CQQB029574
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:42:26 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v7 sched part 0/4] sched: numa: several fixups
Date: Thu, 12 Dec 2013 08:12:19 +0800
Message-Id: <1386807143-15994-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>


Wanpeng Li (4):
  sched/numa: drop sysctl_numa_balancing_settle_count sysctl
  sched/numa: use wrapper function task_node to get node which task is on
  sched/numa: use wrapper function task_faults_idx to calculate index in group_faults
  sched/numa: fix period_slot recalculation

 include/linux/sched/sysctl.h |  1 -
 kernel/sched/debug.c         |  2 +-
 kernel/sched/fair.c          | 17 ++++-------------
 kernel/sysctl.c              |  7 -------
 4 files changed, 5 insertions(+), 22 deletions(-)

-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
