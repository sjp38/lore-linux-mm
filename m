Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5966B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 02:53:19 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 73so6836541pfz.11
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 23:53:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x128sor1448345pgb.311.2017.11.30.23.53.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Nov 2017 23:53:17 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 0/3] mm/cma: manage the memory of the CMA area by using the ZONE_MOVABLE
Date: Fri,  1 Dec 2017 16:53:03 +0900
Message-Id: <1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tony Lindgren <tony@atomide.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

v2
o previous failure in linux-next turned out that it's not the problem of
this patchset. It was caused by the wrong assumption by specific
architecture.

lkml.kernel.org/r/20171114173719.GA28152@atomide.com

o add missing cache flush to the patch "ARM: CMA: avoid double mapping
to the CMA area if CONFIG_HIGHMEM = y"


This patchset is the follow-up of the discussion about the
"Introduce ZONE_CMA (v7)" [1]. Please reference it if more information
is needed.

In this patchset, the memory of the CMA area is managed by using
the ZONE_MOVABLE. Since there is another type of the memory in this zone,
we need to maintain a migratetype for the CMA memory to account
the number of the CMA memory. So, unlike previous patchset, there is
less deletion of the code.

Otherwise, there is no big change.

Motivation of this patchset is described in the commit description of
the patch "mm/cma: manage the memory of the CMA area by using
the ZONE_MOVABLE". Please refer it for more information.

This patchset is based on linux-next-20170822 plus
"mm/page_alloc: don't reserve ZONE_HIGHMEM for ZONE_MOVABLE".

Thanks.

[1]: lkml.kernel.org/r/1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com


Joonsoo Kim (3):
  mm/cma: manage the memory of the CMA area by using the ZONE_MOVABLE
  mm/cma: remove ALLOC_CMA
  ARM: CMA: avoid double mapping to the CMA area if CONFIG_HIGHMEM = y

 arch/arm/mm/dma-mapping.c      | 16 +++++++-
 include/linux/memory_hotplug.h |  3 --
 include/linux/mm.h             |  1 +
 mm/cma.c                       | 83 ++++++++++++++++++++++++++++++++++++------
 mm/compaction.c                |  4 +-
 mm/internal.h                  |  4 +-
 mm/page_alloc.c                | 83 +++++++++++++++++++++++++++---------------
 7 files changed, 145 insertions(+), 49 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
