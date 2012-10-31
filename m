Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id C78086B0068
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 05:15:58 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART5 Patch 0/5] introduce a new boot option 'kernelcore_max_addr'
Date: Wed, 31 Oct 2012 17:21:38 +0800
Message-Id: <1351675303-11786-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

From: Lai Jiangshan <laijs@cn.fujitsu.com>

This patch is part5 of the following patchset:
    https://lkml.org/lkml/2012/10/29/319

The patchset is based on Linus's tree with these three patches already applied:
    https://lkml.org/lkml/2012/10/24/151
    https://lkml.org/lkml/2012/10/26/150

Part1 is here:
    https://lkml.org/lkml/2012/10/31/30

Part2 is here:
    http://marc.info/?l=linux-kernel&m=135166705909544&w=2

Part3 is here:
    http://marc.info/?l=linux-kernel&m=135167050510527&w=2

Part4 is here:
    http://marc.info/?l=linux-kernel&m=135167344211401&w=2

You can apply this patch without the other parts. But it only can work with
part1-5.

We need something like kernelcore_max_addr=XX boot option to limit the
kernelcore upper address.

The memory with higher address will be migratable(movable) and they
are easier to be offline(always ready to be offline when the system don't require
so much memory).

It makes things easy when we dynamic hot-add/remove memory, make better
utilities of memories, and helps for THP.

Lai Jiangshan (1):
  page_alloc: add kernelcore_max_addr

Yasuaki Ishimatsu (4):
  x86: get pg_data_t's memory from other node
  x86: use memblock_set_current_limit() to set memblock.current_limit
  memblock: limit memory address from memblock
  memblock: compare current_limit with end variable at
    memblock_find_in_range_node()

 Documentation/kernel-parameters.txt |  9 +++++++++
 arch/x86/kernel/setup.c             |  4 ++--
 arch/x86/mm/numa.c                  |  8 ++++++--
 include/linux/memblock.h            |  1 +
 mm/memblock.c                       | 10 +++++++---
 mm/page_alloc.c                     | 33 ++++++++++++++++++++++++++++++++-
 6 files changed, 57 insertions(+), 8 deletions(-)

-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
