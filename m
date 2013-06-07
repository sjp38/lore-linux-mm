Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 0454C6B0034
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 05:54:26 -0400 (EDT)
Message-ID: <51B1AD2F.4030702@cn.fujitsu.com>
Date: Fri, 07 Jun 2013 17:51:43 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 0/3] mm, vmalloc: cleanup for vmap block
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: chanho.min@lge.com, Johannes Weiner <hannes@cmpxchg.org>, iamjoonsoo.kim@lge.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

This patchset is a cleanup for vmap block. And similar/same
patches has been submitted before:
- Johannes Weiner's patch: https://lkml.org/lkml/2011/4/14/619
- Chanho Min's patch: https://lkml.org/lkml/2013/2/6/810

In Johannes's thread, Mel suggested to figure out if this
bitmap was not supposed to be doing something useful and depending
on that implement recycling of partially used vmap blocks.

Anyway, just as Johannes said, we shouldn't leave these dead/unused
code as is, because it really is a waste of time for cpus and readers
of the code. And this cleanup doesn't prevent anyone from improving
the algorithm later on.

Based on the two patches before, I split the cleanup into three
small pieces that may be more clear.

Zhang Yanfei (3):
  mm, vmalloc: Remove dead code in vb_alloc
  mm, vmalloc: Remove unused purge_fragmented_blocks_thiscpu
  mm, vmalloc: Remove alloc_map from vmap_block

 mm/vmalloc.c |   24 +-----------------------
 1 files changed, 1 insertions(+), 23 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
