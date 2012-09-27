Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 3BD8C6B005D
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 03:00:17 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 0/3] memory_hotplug: fix memory hotplug bug
Date: Thu, 27 Sep 2012 14:47:47 +0800
Message-Id: <1348728470-5580-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, Jianguo Wu <wujianguo@huawei.com>, Kay Sievers <kay.sievers@vrfy.org>, Greg Kroah-Hartman <gregkh@suse.de>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@suse.de>, linux-doc@vger.kernel.org, linux-mm@kvack.org

We found 3 bug while we test and develop memory hotplug.

PATCH1~2: the old code does not handle node_states[N_NORMAL_MEMORY] correctly,
it corrupts the memory.

PATCH3: move the modification of zone_start_pfn into corresponding lock.

CC: Rob Landley <rob@landley.net>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Jiang Liu <jiang.liu@huawei.com>
CC: Jianguo Wu <wujianguo@huawei.com>
CC: Kay Sievers <kay.sievers@vrfy.org>
CC: Greg Kroah-Hartman <gregkh@suse.de>
CC: Xishi Qiu <qiuxishi@huawei.com>
CC: Mel Gorman <mgorman@suse.de>
CC: linux-doc@vger.kernel.org
CC: linux-kernel@vger.kernel.org
CC: linux-mm@kvack.org

Lai Jiangshan (3):
  memory_hotplug: fix missing nodemask management
  slub, hotplug: ignore unrelated node's hot-adding and hot-removing
  memory,hotplug: Don't modify the zone_start_pfn outside of
    zone_span_writelock()

 Documentation/memory-hotplug.txt |    5 ++-
 include/linux/memory.h           |    1 +
 mm/memory_hotplug.c              |   96 +++++++++++++++++++++++++++++++-------
 mm/page_alloc.c                  |    3 +-
 mm/slub.c                        |    4 +-
 5 files changed, 87 insertions(+), 22 deletions(-)

-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
