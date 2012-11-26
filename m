Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id F2BD96B0044
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 05:49:48 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PATCH 0/5] cpu-hotplug,memory-hotplug: bug fix for offlining node
Date: Mon, 26 Nov 2012 18:20:22 +0800
Message-Id: <1353925227-1877-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-acpi@vger.kernel.org, x86@kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <len.brown@intel.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

This patchset is based on the following patchset:
https://lkml.org/lkml/2012/11/1/93

The following patch in mm tree can be dropped now:
    cpu_hotplug-unmap-cpu2node-when-the-cpu-is-hotremoved.patch

Tang Chen (1):
  Do not use cpu_to_node() to find an offlined cpu's node.

Wen Congyang (4):
  cpu_hotplug: clear apicid to node when the cpu is hotremoved
  memory-hotplug: export the function try_offline_node()
  cpu-hotplug, memory-hotplug: try offline the node when hotremoving a
    cpu
  cpu-hotplug,memory-hotplug: clear cpu_to_node() when offlining the
    node

 arch/x86/kernel/acpi/boot.c     |  4 ++++
 drivers/acpi/processor_driver.c |  2 ++
 include/linux/memory_hotplug.h  |  2 ++
 kernel/sched/core.c             | 28 +++++++++++++++++++---------
 mm/memory_hotplug.c             | 33 +++++++++++++++++++++++++++++++--
 5 files changed, 58 insertions(+), 11 deletions(-)

-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
