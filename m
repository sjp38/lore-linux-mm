Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 80AFE6B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 19:50:13 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so8883146pbc.29
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:50:13 -0800 (PST)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id g5si11829782pav.259.2013.12.10.16.50.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 16:50:12 -0800 (PST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 06:20:08 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 18B99E0056
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:22:25 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBB0o14C44236842
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:20:01 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBB0o4SR018026
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:20:05 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v5 0/8] mm: sched: numa: several fixups
Date: Wed, 11 Dec 2013 08:49:53 +0800
Message-Id: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Hi Andrew,

I rebase this patchset against latest mmotm tree since Mel's [PATCH 00/17] 
NUMA balancing segmentation fault fixes and misc followups v4 merged. Several 
patches are dropped in my v5 since one is merged in tip tree and other three 
patches conflict with Mel's series. I have already picked up everybody's Acked-by
or Reviewed-by in v5 and hopefully they can be merged soon. ;-)

Wanpeng Li (8):
  sched/numa: fix set cpupid on page migration twice against thp
  sched/numa: drop sysctl_numa_balancing_settle_count sysctl
  sched/numa: use wrapper function task_node to get node which task is on
  sched/numa: fix set cpupid on page migration twice against normal page
  sched/numa: use wrapper function task_faults_idx to calculate index in group_faults
  sched/numa: fix period_slot recalculation
  sched/numa: fix record hinting faults check
  sched/numa: drop unnecessary variable in task_weight

 include/linux/sched/sysctl.h |    1 -
 kernel/sched/debug.c         |    2 +-
 kernel/sched/fair.c          |   30 +++++++-----------------------
 kernel/sysctl.c              |    7 -------
 mm/migrate.c                 |    4 ----
 5 files changed, 8 insertions(+), 36 deletions(-)

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
