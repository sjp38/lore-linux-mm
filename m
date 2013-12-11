Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id DFAED6B003B
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 05:16:29 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id wn1so6675290obc.19
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 02:16:29 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id ns8si12981460obc.61.2013.12.11.02.16.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 02:16:28 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 15:46:14 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 69613E0057
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 15:48:30 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBBAG7va45875298
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 15:46:07 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBBAG9sx027037
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 15:46:09 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v6 0/6] mm: sched: numa: several fixups
Date: Wed, 11 Dec 2013 18:15:55 +0800
Message-Id: <1386756961-3887-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Hi Andrew,

I rebase this patchset against latest mmotm tree since Mel's [PATCH 00/17]
NUMA balancing segmentation fault fixes and misc followups v4 merged. Several
patches are dropped in my v6 since one is merged in tip tree and other three
patches conflict with Mel's series. I have already picked up everybody's Acked-by
or Reviewed-by in v6 and hopefully they can be merged soon. ;-)

Wanpeng Li (6):
  sched/numa: fix set cpupid on page migration twice against thp
  sched/numa: drop sysctl_numa_balancing_settle_count sysctl
  sched/numa: use wrapper function task_node to get node which task is on
  sched/numa: fix set cpupid on page migration twice against normal page
  sched/numa: use wrapper function task_faults_idx to calculate index in group_faults
  sched/numa: fix period_slot recalculation

 include/linux/sched/sysctl.h |    1 -
 kernel/sched/debug.c         |    2 +-
 kernel/sched/fair.c          |   17 ++++-------------
 kernel/sysctl.c              |    7 -------
 mm/migrate.c                 |    4 ----
 5 files changed, 5 insertions(+), 26 deletions(-)

-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
