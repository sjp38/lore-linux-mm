Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 68FFE6B0071
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 03:58:32 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART3 Patch 00/14] introduce N_MEMORY
Date: Wed, 31 Oct 2012 16:03:58 +0800
Message-Id: <1351670652-9932-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

From: Lai Jiangshan <laijs@cn.fujitsu.com>

This patch is part3 of the following patchset:
    https://lkml.org/lkml/2012/10/29/319

Part1 is here:
    https://lkml.org/lkml/2012/10/31/30

Part2 is here:
    http://marc.info/?l=linux-kernel&m=135166705909544&w=2

You can apply this patchset without the other parts.

we need a node which only contains movable memory. This feature is very
important for node hotplug. So we will add a new nodemask
for all memory. N_MEMORY contains movable memory but N_HIGH_MEMORY
doesn't contain it.

We don't remove N_HIGH_MEMORY because it can be used to search which
nodes contains memory that the kernel can use.

The movable node will implemtent in part4. So N_MEMORY is equal to N_HIGH_MEMORY
now.


Lai Jiangshan (14):
  node_states: introduce N_MEMORY
  cpuset: use N_MEMORY instead N_HIGH_MEMORY
  procfs: use N_MEMORY instead N_HIGH_MEMORY
  memcontrol: use N_MEMORY instead N_HIGH_MEMORY
  oom: use N_MEMORY instead N_HIGH_MEMORY
  mm,migrate: use N_MEMORY instead N_HIGH_MEMORY
  mempolicy: use N_MEMORY instead N_HIGH_MEMORY
  hugetlb: use N_MEMORY instead N_HIGH_MEMORY
  vmstat: use N_MEMORY instead N_HIGH_MEMORY
  kthread: use N_MEMORY instead N_HIGH_MEMORY
  init: use N_MEMORY instead N_HIGH_MEMORY
  vmscan: use N_MEMORY instead N_HIGH_MEMORY
  page_alloc: use N_MEMORY instead N_HIGH_MEMORY change the node_states
    initialization
  hotplug: update nodemasks management

 Documentation/cgroups/cpusets.txt |  2 +-
 Documentation/memory-hotplug.txt  |  5 ++-
 arch/x86/mm/init_64.c             |  4 +-
 drivers/base/node.c               |  2 +-
 fs/proc/kcore.c                   |  2 +-
 fs/proc/task_mmu.c                |  4 +-
 include/linux/cpuset.h            |  2 +-
 include/linux/memory.h            |  1 +
 include/linux/nodemask.h          |  1 +
 init/main.c                       |  2 +-
 kernel/cpuset.c                   | 32 +++++++-------
 kernel/kthread.c                  |  2 +-
 mm/hugetlb.c                      | 24 +++++------
 mm/memcontrol.c                   | 18 ++++----
 mm/memory_hotplug.c               | 87 ++++++++++++++++++++++++++++++++-------
 mm/mempolicy.c                    | 12 +++---
 mm/migrate.c                      |  2 +-
 mm/oom_kill.c                     |  2 +-
 mm/page_alloc.c                   | 40 ++++++++++--------
 mm/page_cgroup.c                  |  2 +-
 mm/vmscan.c                       |  4 +-
 mm/vmstat.c                       |  4 +-
 22 files changed, 161 insertions(+), 93 deletions(-)

-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
