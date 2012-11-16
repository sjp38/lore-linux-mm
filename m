Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id B1E176B0068
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 06:51:57 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART4 Patch v2 0/2] memory-hotplug: allow online/offline memory to result movable node
Date: Fri, 16 Nov 2012 19:58:08 +0800
Message-Id: <1353067090-19468-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>, Wen Congyang <wency@cn.fujitsu.com>

This patch is part4 of the following patchset:
    https://lkml.org/lkml/2012/10/29/319

Part1 is here:
    https://lkml.org/lkml/2012/10/31/30

Part2 is here:
    https://lkml.org/lkml/2012/10/31/73

Part3 is here:
    https://lkml.org/lkml/2012/11/15/111

Part5 is here:
    https://lkml.org/lkml/2012/10/31/145

Part6 is here:
    https://lkml.org/lkml/2012/10/31/248

You must apply part1-3 before applying this patchset.

Note: part1-3 are in mm tree now. part5 are being reimplemented(We will
post it some days later). part6 is still in discussion.

we need a node which only contains movable memory. This feature is very
important for node hotplug. If a node has normal/highmem, the memory
may be used by the kernel and can't be offlined. If the node only contains
movable memory, we can offline the memory and the node.

Changes from v1 to v2:
1. Add Tested-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
2. Add my Signed-off-by, because I am on the the patch delivery path.

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
