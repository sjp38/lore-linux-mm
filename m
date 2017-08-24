From: js1304@gmail.com
Subject: [PATCH 0/3] mm/cma: manage the memory of the CMA area by using the ZONE_MOVABLE
Date: Thu, 24 Aug 2017 15:36:30 +0900
Message-ID: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>
List-Id: linux-mm.kvack.org

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

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

 arch/arm/mm/dma-mapping.c      |  8 +++-
 include/linux/memory_hotplug.h |  3 --
 include/linux/mm.h             |  1 +
 mm/cma.c                       | 83 ++++++++++++++++++++++++++++++++++++------
 mm/compaction.c                |  4 +-
 mm/internal.h                  |  4 +-
 mm/page_alloc.c                | 83 +++++++++++++++++++++++++++---------------
 7 files changed, 137 insertions(+), 49 deletions(-)

-- 
2.7.4
