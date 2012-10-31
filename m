Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 7766C6B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 04:50:04 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART4 Patch 0/2] memory-hotplug: allow online/offline memory to result movable node
Date: Wed, 31 Oct 2012 16:15:32 +0800
Message-Id: <1351671334-10243-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

From: Lai Jiangshan <laijs@cn.fujitsu.com>

This patch is part4 of the following patchset:
    https://lkml.org/lkml/2012/10/29/319

Part1 is here:
    https://lkml.org/lkml/2012/10/31/30

Part2 is here:
    http://marc.info/?l=linux-kernel&m=135166705909544&w=2

Part3 is here:
    http://marc.info/?l=linux-kernel&m=135167050510527&w=2

You must apply part1-3 before applying this patchset.

we need a node which only contains movable memory. This feature is very
important for node hotplug. If a node has normal/highmem, the memory
may be used by the kernel and can't be offlined. If the node only contains
movable memory, we can offline the memory and the node.


Lai Jiangshan (2):
  numa: add CONFIG_MOVABLE_NODE for movable-dedicated node
  memory_hotplug: allow online/offline memory to result movable node

 drivers/base/node.c      |  6 ++++++
 include/linux/nodemask.h |  4 ++++
 mm/Kconfig               |  8 ++++++++
 mm/memory_hotplug.c      | 16 ++++++++++++++++
 mm/page_alloc.c          |  3 +++
 5 files changed, 37 insertions(+)

-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
